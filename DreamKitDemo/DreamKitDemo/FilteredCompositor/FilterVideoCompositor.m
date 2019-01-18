//
//  FilterVideoCompositor.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/1/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "FilterVideoCompositor.h"
#import "FilterVideoCompositionInstruction.h"
@import CoreImage;
#import "DMKAdjustment.h"
#import "DMKRecipe.h"
#import <UIKit/UIImage.h>
#import "DMKTransformUtilities.h"
#import "DreamKit.h"

@implementation CIFilter (VideoTransition)

+ (instancetype)filterForVideoTransitionType:(VideoTransitionType)videoTransitionType {
    
    CIFilter *filter = nil;
    
    switch (videoTransitionType) {
        case VideoTransitionTypeAccordionFold: {
            filter = [CIFilter filterWithName:@"CIAccordionFoldTransition"];
            break;
        }
        case VideoTransitionTypeBarsSwipe: {
            filter = [CIFilter filterWithName:@"CIBarsSwipeTransition"];
            break;
        }
        case VideoTransitionTypeDissolve: {
            filter = [CIFilter filterWithName:@"CIDissolveTransition"];
            break;
        }
        case VideoTransitionTypeFlash: {
            filter = [CIFilter filterWithName:@"CIFlashTransition"];
            break;
        }
        case VideoTransitionTypeMod: {
            filter = [CIFilter filterWithName:@"CIModTransition"];
            break;
        }
        case VideoTransitionTypePageCurl: {
            filter = [CIFilter filterWithName:@"CIPageCurlWithShadowTransition"];
            break;
        }
        case VideoTransitionTypeSwipe: {
            filter = [CIFilter filterWithName:@"CISwipeTransition"];
            break;
        }
            
        default:
            break;
    }
    
    return filter;
}

@end

@interface FilterVideoCompositor ()

@property (nonatomic, assign) BOOL shouldCancelAllRequests;
@property (nonatomic, assign) BOOL renderContextDidChange;
@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (nonatomic, strong) dispatch_queue_t renderContextQueue;
@property (nonatomic, strong) AVVideoCompositionRenderContext *renderContext;
@property (nonatomic, strong) CIContext *ciContext;
//@property (nonatomic, assign) CVPixelBufferRef previousBuffer;
@property (nonatomic, assign) NSInteger lastUpdateID;
@property (nonatomic, assign) CGAffineTransform renderTransform;

@end

@implementation FilterVideoCompositor

- (NSDictionary *)sourcePixelBufferAttributes {
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
              (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @YES};
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext {
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
              (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @YES};
}

- (instancetype)init {
    self = [super init];
    if (self)
    {
        _renderingQueue = dispatch_queue_create("com.museworks.dreamkit.renderingqueue", DISPATCH_QUEUE_SERIAL);
        _renderContextQueue = dispatch_queue_create("com.museworks.dreamkit.rendercontextqueue", DISPATCH_QUEUE_SERIAL);
        _renderContextDidChange = NO;
        
        EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{kCIContextWorkingColorSpace : [NSNull null]};
        _ciContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    }
    return self;
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request {
    @autoreleasepool {
        dispatch_async(_renderingQueue,^() {
            if (_shouldCancelAllRequests) {
                [request finishCancelledRequest];
            } else {
                NSError *err = nil;
                
                CVPixelBufferRef resultPixels = [self newRenderedPixelBufferForRequest:request error:&err];

                if (resultPixels) {
                    [request finishWithComposedVideoFrame:resultPixels];
                    CFRelease(resultPixels);
                } else {
                    [request finishWithError:err];
                }
            }
        });
    }
}

- (void)cancelAllPendingVideoCompositionRequests {
    // pending requests will call finishCancelledRequest, those already rendering will call finishWithComposedVideoFrame
    _shouldCancelAllRequests = YES;
    
    dispatch_barrier_async(_renderingQueue, ^() {
        // start accepting requests again
        _shouldCancelAllRequests = NO;
    });
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
    dispatch_sync(_renderContextQueue, ^() {
        _renderContext = newRenderContext;
        _renderContextDidChange = YES;
    });
}

static Float64 factorForTimeInRange(CMTime time, CMTimeRange range) /* 0.0 -> 1.0 */
{
    CMTime elapsed = CMTimeSubtract(time, range.start);
    return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration);
}

- (CVPixelBufferRef)newRenderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request error:(NSError **)errOut {

    FilterVideoCompositionInstruction *currentInstruction = request.videoCompositionInstruction;

    CVPixelBufferRef dstPixels = [self.renderContext newPixelBuffer];
    
    CGSize destinationSize = CGSizeMake(CVPixelBufferGetWidth(dstPixels), CVPixelBufferGetHeight(dstPixels));

    if ([currentInstruction isKindOfClass:[TransitioningFilterVideoCompositionInstruction class]]) {
        // tweenFactor indicates how far within that timeRange are we rendering this frame. This is normalized to vary between 0.0 and 1.0.
        // 0.0 indicates the time at first frame in that videoComposition timeRange
        // 1.0 indicates the time at last frame in that videoComposition timeRange
        float tweenFactor = factorForTimeInRange(request.compositionTime, request.videoCompositionInstruction.timeRange);
        
        TransitioningFilterVideoCompositionInstruction *transitionInstruction = (TransitioningFilterVideoCompositionInstruction *)currentInstruction;
        CVPixelBufferRef foregroundSourceBuffer = [request sourceFrameByTrackID:transitionInstruction.foregroundTrackID];
        CVPixelBufferRef backgroundSourceBuffer = [request sourceFrameByTrackID:transitionInstruction.backgroundTrackID];
        
        CIImage *foregroundImage = [self prepareFilteredImageWithSize:destinationSize fromSourceBuffer:foregroundSourceBuffer instructionAttributes:transitionInstruction.foregroundAttributes];
        CIImage *backgroundImage = [self prepareFilteredImageWithSize:destinationSize fromSourceBuffer:backgroundSourceBuffer instructionAttributes:transitionInstruction.backgroundAttributes];
        
        CIImage *transitionedImage = [self prepareVideoTransitionType:transitionInstruction.videoTransitionType foregroundImage:foregroundImage backgroundImage:backgroundImage tweenFactor:tweenFactor];

        [self.ciContext render:transitionedImage toCVPixelBuffer:dstPixels];

    } else {
        CVPixelBufferRef foregroundSourceBuffer = [request sourceFrameByTrackID:currentInstruction.foregroundTrackID];
        CIImage *filteredImage = [self prepareFilteredImageWithSize:destinationSize fromSourceBuffer:foregroundSourceBuffer instructionAttributes:currentInstruction.foregroundAttributes];
        [self.ciContext render:filteredImage toCVPixelBuffer:dstPixels];
    }

    return dstPixels;
}

#pragma mark - Instruction handlers

- (CIImage *)prepareFilteredImageWithSize:(CGSize)destinationSize fromSourceBuffer:(CVPixelBufferRef)sourcePixelBuffer instructionAttributes:(FilterInstructionAttributes *)attributes {
    
    CIImage *scaledImage = [CIImage imageWithCVPixelBuffer:sourcePixelBuffer];
    
    scaledImage = [scaledImage dmk_imageWithSize:self.renderContext.size rotation:attributes.rotation contentMode:attributes.contentMode];

    _renderContextDidChange = NO;
    
    CIImage *filteredImage;
    if (attributes.recipe) {
        filteredImage = [[attributes.recipe applyAdjustmentsToImage:scaledImage] imageByCroppingToRect:scaledImage.extent];
    } else {
        filteredImage = scaledImage;
    }
    
    CIImage *centeredAndFilteredImage = [filteredImage dmk_imageByCenteringInSize:destinationSize contentMode:attributes.contentMode];
    
    BOOL needsBackgroundEffect = (attributes.contentMode != DMKContentModeScaleAspectFill);
    
    CIImage *finishedImage = nil;
    
    if (needsBackgroundEffect) {
        CIImage *blurredBackgroundImage = [scaledImage dmk_imageByApplyingBlurRadius:80];
        
        CIImage *centeredAndBlurredBackgroundImage = [blurredBackgroundImage dmk_imageByCenteringInSize:destinationSize contentMode:DMKContentModeScaleAspectFill];
        
        CIFilter *compositionFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
        [compositionFilter setValue:centeredAndFilteredImage forKey:kCIInputImageKey];
        [compositionFilter setValue:centeredAndBlurredBackgroundImage forKey:kCIInputBackgroundImageKey];
        
        finishedImage = compositionFilter.outputImage;
    } else {
        finishedImage = centeredAndFilteredImage;
    }
    
    return finishedImage;
}

- (CIImage *)prepareVideoTransitionType:(VideoTransitionType)videoTransitionType foregroundImage:(CIImage *)foregroundImage backgroundImage:(CIImage *)backgroundImage tweenFactor:(CGFloat)tweenFactor {
    
    CIFilter *transitionFilter = [CIFilter filterForVideoTransitionType:videoTransitionType];
    [transitionFilter setValue:foregroundImage forKey:@"inputImage"];
    [transitionFilter setValue:backgroundImage forKey:@"inputTargetImage"];
    [transitionFilter setValue:@(tweenFactor) forKey:@"inputTime"];
    if ([transitionFilter.inputKeys containsObject:@"inputExtent"]) {
        [transitionFilter setValue:[CIVector vectorWithCGRect:foregroundImage.extent] forKey:@"inputExtent"];
    }
    
    return transitionFilter.outputImage;
}

@end

    //
//  PhotoEditor.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/18/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "PhotoEditor.h"
#import "DreamKit.h"
#import "DMKExifOrientation.h"

@interface PhotoEditor ()

@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) dispatch_queue_t renderQueue;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation PhotoEditor

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 1;
    
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{kCIContextUseSoftwareRenderer: @NO};
    _ciContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    
    return self;
}

- (void)setInputImage:(UIImage *)image {
    CGSize size = CGSizeMake(1200, 1200);
    
    self.operationQueue.suspended = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
        inputImage = [inputImage imageByApplyingOrientation:dmk_exifOrientationFromUIImageOrientation(image.imageOrientation)];
        
        CGRect extent = inputImage.extent;
        CGFloat horizontalScale = (size.width) / extent.size.width;
        CGFloat verticalScale = (size.height) / extent.size.height;
        
        CGFloat scale = MIN(MIN(horizontalScale, verticalScale), 1.0);
        
        CIFilter *filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        [filter setValue:@(scale) forKey:kCIInputScaleKey];
        [filter setValue:@(1.0) forKey:kCIInputAspectRatioKey];
        
        CGImageRef cgImage = [self.ciContext createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
        
        UIImage *outputImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        _inputImage = outputImage;
        self.operationQueue.suspended = NO;
    });
}

- (void)cancelRendering {
    [self.operationQueue cancelAllOperations];
}

- (void)renderImage {
    [self cancelRendering];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        if (self.shouldCancelAllRequests) {
//            NSLog(@"dropped request");
//            return;
//        }
        
        CIImage *inputImage = [CIImage imageWithCGImage:self.inputImage.CGImage];
    
        CIImage *filteredImage = [self.recipe applyAdjustmentsToImage:inputImage];
        
        CGImageRef cgImage = [self.ciContext createCGImage:filteredImage fromRect:filteredImage.extent];
        
        UIImage *outputImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        NSLog(@"Rendered");
        
        [self.delegate photoEditor:self didRenderImage:outputImage];
    }];
    
    [self.operationQueue addOperation:operation];
}

@end

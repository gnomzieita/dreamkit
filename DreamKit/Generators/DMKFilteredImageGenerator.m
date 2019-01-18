//
//  DMKFilteredImageGenerator.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/11/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKFilteredImageGenerator.h"
#import "DMKExifOrientation.h"

@interface DMKFilteredImageGenerator ()

@property (strong, nonatomic) CIContext *context;
@property (strong, nonatomic) dispatch_queue_t renderQueue;

@end

@implementation DMKFilteredImageGenerator

+ (instancetype)sharedGenerator {
    static DMKFilteredImageGenerator *sharedGenerator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGenerator = [[self alloc] init];
    });
    
    return sharedGenerator;
}

- (dispatch_queue_t)renderQueue {
    if (_renderQueue == nil) {
        _renderQueue = dispatch_queue_create("com.museworks.dreamkit.renderQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _renderQueue;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSLog(@"creating new context");
    
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{kCIContextUseSoftwareRenderer: @NO};
    _context = [CIContext contextWithEAGLContext:eaglContext options:options];
    
    return self;
}

- (void)applyRecipe:(DMKRecipe *)recipe toImage:(UIImage *)image completionHandler:(void (^)(UIImage * _Nullable, NSError * _Nullable))completionHandler {
    if (recipe == nil) {
        completionHandler(image, nil);
        return;
    }
    
    dispatch_async(self.renderQueue, ^{
        NSError *error = nil;
        UIImage *finishedImage = [self applyRecipe:recipe toImage:image error:&error];
        completionHandler(finishedImage, error);
    });
}

- (UIImage *)applyRecipe:(DMKRecipe *)recipe toImage:(UIImage *)image error:(NSError * _Nullable __autoreleasing *)error {
    if (recipe == nil || image == nil) {
        return image;
    }
    
    CIImage *sourceImage = [CIImage imageWithCGImage:image.CGImage];
    sourceImage = [sourceImage imageByApplyingOrientation:dmk_exifOrientationFromUIImageOrientation(image.imageOrientation)];
    
    CIImage *filteredImage = [recipe applyAdjustmentsToImage:sourceImage];
    
    CGImageRef cgImage = [self.context createCGImage:filteredImage
                                            fromRect:filteredImage.extent];
    
    UIImage *finishedImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return finishedImage;
}

@end

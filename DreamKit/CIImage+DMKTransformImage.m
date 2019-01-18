//
//  CIImage+DMKTransformImage.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/8/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "CIImage+DMKTransformImage.h"

@implementation CIImage (DMKTransformImage)

- (CIImage * _Nullable)dmk_imageByCenteringInSize:(CGSize)targetSize contentMode:(DMKContentMode)contentMode {
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    [cropFilter setValue:self forKey:@"inputImage"];
    [cropFilter setValue:[CIVector vectorWithCGRect:CGRectInset((CGRect){CGPointZero, self.extent.size}, 0.00001, 0.00001)] forKey:@"inputRectangle"];
    
    CIFilter *translateFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [translateFilter setValue:cropFilter.outputImage forKey:kCIInputImageKey];
    
    CGAffineTransform newTransform = dmk_CGAffineTransformToCenterInContainer(self.extent.size, targetSize, contentMode);
    
    [translateFilter setValue:[NSValue valueWithBytes:&newTransform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    return translateFilter.outputImage;
}

- (CIImage * _Nullable)dmk_imageWithSize:(CGSize)containerSize rotation:(CGFloat)rotation contentMode:(DMKContentMode)contentMode {
    CGSize contentSize = self.extent.size;
    
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(rotation);
    
    contentSize = CGSizeApplyAffineTransform(contentSize, rotateTransform);
    contentSize.width = ABS(contentSize.width);
    contentSize.height = ABS(contentSize.height);
    
    CGSize chosenScale = dmk_contentScaleForSizeInSize(contentSize, containerSize, contentMode);

    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(chosenScale.width, chosenScale.height), rotateTransform);
    
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [transformFilter setValue:self forKey:@"inputImage"];
    [transformFilter setValue:[NSValue valueWithBytes:&transform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    CIImage *rotatedImage = [transformFilter outputImage];
    
    CGAffineTransform correctionTransform = CGAffineTransformMakeTranslation(-rotatedImage.extent.origin.x, -rotatedImage.extent.origin.y);
    CIFilter *correctionTransformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [correctionTransformFilter setValue:rotatedImage forKey:@"inputImage"];
    [correctionTransformFilter setValue:[NSValue valueWithBytes:&correctionTransform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    return correctionTransformFilter.outputImage;
}

- (CIImage * _Nullable)dmk_imageMovedToIdentityOrigin {
    const CGPoint origin = self.extent.origin;
    if (origin.x == 0 && origin.y == 0) {
        return [self copy];
    }
    
    CGAffineTransform correctionTransform = CGAffineTransformMakeTranslation(-origin.x, -origin.y);
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [transformFilter setValue:self forKey:@"inputImage"];
    [transformFilter setValue:[NSValue valueWithBytes:&correctionTransform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    return transformFilter.outputImage;
}

@end

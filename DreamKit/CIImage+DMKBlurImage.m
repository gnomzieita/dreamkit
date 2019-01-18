//
//  CIImage+DMKBlurImage.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/8/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "CIImage+DMKBlurImage.h"

@implementation CIImage (DMKBlurImage)

- (CIImage *)dmk_imageByApplyingBlurRadius:(CGFloat)blurRadius {
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIBoxBlur"];
    [blurFilter setValue:[self imageByClampingToExtent] forKey:@"inputImage"];
    [blurFilter setValue:@(blurRadius) forKey:@"inputRadius"];
    
    CIImage *outputImage = blurFilter.outputImage;
    outputImage = [outputImage imageByCroppingToRect:self.extent];
    return outputImage ;
}

@end

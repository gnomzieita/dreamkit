//
//  DMKTrueClarityAdjustment.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/18/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"
#import "DMKClarityFilter.h"

@implementation DMKStructureAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentStructureKey;
}

- (NSString *)title {
    return @"Clarity";
}

- (CGFloat)minAmount {
    return -1.0;
}

- (CGFloat)maxAmount {
    return 1.0;
}

- (CGFloat)initialAmount {
    return 0.0;
}

- (CIImage *)applyToImage:(CIImage *)image {
    DMKClarityFilter *clarityFilter = [[DMKClarityFilter alloc] init];
    clarityFilter.inputImage = image;
    clarityFilter.amount = @(self.amount * 0.02);
    
    CIFilter *unsharpFilter = nil;
    if (self.amount >= 0) {
        unsharpFilter = [CIFilter filterWithName:@"CIUnsharpMask"];
        [unsharpFilter setValue:clarityFilter.outputImage forKey:@"inputImage"];
        [unsharpFilter setValue:@(self.amount * 9.0) forKey:kCIInputRadiusKey];
    } else {
        unsharpFilter = [CIFilter filterWithName:@"CIGloom"];
        [unsharpFilter setValue:[clarityFilter.outputImage imageByClampingToExtent] forKey:@"inputImage"];
        [unsharpFilter setValue:@(0.4) forKey:@"inputIntensity"];
        [unsharpFilter setValue:@(-self.amount * 10.0) forKey:kCIInputRadiusKey];
    }
    
    return [unsharpFilter.outputImage imageByCroppingToRect:image.extent];
    
//    CIFilter *vibranceFilter = [CIFilter filterWithName:@"CIVibrance"];
//    [vibranceFilter setValue:unsharpFilter.outputImage forKey:@"inputImage"];
//    [vibranceFilter setValue:@(self.amount * 0.3) forKey:@"inputAmount"];
//    
//    return [vibranceFilter.outputImage imageByCroppingToRect:image.extent];
}

@end

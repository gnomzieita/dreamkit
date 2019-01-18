//
//  DMKFadeAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/31/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKFadeAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentFadeKey;
}

- (NSString *)title {
    return @"Fade";
}

- (CGFloat)minAmount {
    return 0;
}

- (CGFloat)maxAmount {
    return 10.0;
}

- (CGFloat)initialAmount {
    return 0;
}

- (CIFilter *)filter {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use applyToImage" userInfo:nil];
}

- (CIImage *)applyToImage:(CIImage *)image {
    CGFloat clampAmount = self.amount * 0.0015;
    
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIColorClamp"];
    [clampFilter setDefaults];
    [clampFilter setValue:image forKey:kCIInputImageKey];
    [clampFilter setValue:[CIVector vectorWithX:clampAmount Y:clampAmount Z:clampAmount W:0] forKey:@"inputMinComponents"];
    [clampFilter setValue:[CIVector vectorWithX:1.0 - clampAmount Y:1.0 - clampAmount Z:1.0 - clampAmount W:1] forKey:@"inputMaxComponents"];
    
    CIFilter *contrastFilter = [CIFilter filterWithName:@"CIColorControls"];
    [contrastFilter setDefaults];
    [contrastFilter setValue:clampFilter.outputImage forKey:kCIInputImageKey];
    [contrastFilter setValue:@(1.0 - (self.amount * 0.006)) forKey:kCIInputContrastKey];
    return contrastFilter.outputImage;
}

@end

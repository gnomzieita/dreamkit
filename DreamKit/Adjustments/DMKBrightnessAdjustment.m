//
//  DMKBrightnessAdjustment.m
//  DreamKitDemo
//
//  Created by Chris Webb on 10/18/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKBrightnessAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentBrightnessKey;
}

- (NSString *)title {
    return @"Brightness";
}

- (CGFloat)minAmount {
    return -1.0;
}

- (CGFloat)maxAmount {
    return 1.0;
}

- (CGFloat)initialAmount {
    return 0;
}


- (CIImage *)applyToImage:(CIImage *)image {
    CGFloat luminosity = self.amount;
    
    if (luminosity == self.initialAmount) {
        return image;
    }
    
    CIFilter *toneCurveFilter = [CIFilter filterWithName:@"CIToneCurve"];
    [toneCurveFilter setValue:image forKey:kCIInputImageKey];
    
    if (luminosity > self.initialAmount) {
        [toneCurveFilter setValue:[CIVector vectorWithX:0.0  Y:luminosity]                           forKey:@"inputPoint0"];
        [toneCurveFilter setValue:[CIVector vectorWithX:0.25 Y:luminosity + 0.25 * (1 - luminosity)] forKey:@"inputPoint1"];
        [toneCurveFilter setValue:[CIVector vectorWithX:0.50 Y:luminosity + 0.50 * (1 - luminosity)] forKey:@"inputPoint2"];
        [toneCurveFilter setValue:[CIVector vectorWithX:0.75 Y:luminosity + 0.75 * (1 - luminosity)] forKey:@"inputPoint3"];
        [toneCurveFilter setValue:[CIVector vectorWithX:1.0  Y:1.0]                                  forKey:@"inputPoint4"];
    } else {
        [toneCurveFilter setValue:[CIVector vectorWithX:0.0  Y:0.0]                     forKey:@"inputPoint0"];
        [toneCurveFilter setValue:[CIVector vectorWithX:0.25 Y:0.25 * (1 + luminosity)] forKey:@"inputPoint1"];
        [toneCurveFilter setValue:[CIVector vectorWithX:0.50 Y:0.50 * (1 + luminosity)] forKey:@"inputPoint2"];
        [toneCurveFilter setValue:[CIVector vectorWithX:0.75 Y:0.75 * (1 + luminosity)] forKey:@"inputPoint3"];
        [toneCurveFilter setValue:[CIVector vectorWithX:1.0  Y:1.0 + luminosity]          forKey:@"inputPoint4"];
    }
    
    return toneCurveFilter.outputImage;
}

@end

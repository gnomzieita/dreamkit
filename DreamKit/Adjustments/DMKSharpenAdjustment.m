//
//  DMKSharpenAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/31/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKSharpenAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentSharpenKey;
}

- (NSString *)title {
    return @"Sharpen";
}

- (CGFloat)minAmount {
    return 0;
}

- (CGFloat)maxAmount {
    return 0.8;
}

- (CGFloat)initialAmount {
    return 0;
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CIUnsharpMask"];
    [filter setDefaults];
    [filter setValue:@(self.amount) forKey:kCIInputIntensityKey];
    return filter;
}


@end

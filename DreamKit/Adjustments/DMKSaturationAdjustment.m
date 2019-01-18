//
//  DMKSaturationAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/15/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKSaturationAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentSaturationKey;
}

- (NSString *)title {
    return @"Saturation";
}

- (CGFloat)minAmount {
    return 0;
}

- (CGFloat)maxAmount {
    return 2.0;
}

- (CGFloat)initialAmount {
    return 1.0;
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setDefaults];
    [filter setValue:@(self.amount) forKey:kCIInputSaturationKey];
    return filter;
}

@end

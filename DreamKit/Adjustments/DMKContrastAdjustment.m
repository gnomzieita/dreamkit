//
//  DMKContrastAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/31/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKContrastAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentContrastKey;
}

- (NSString *)title {
    return @"Contrast";
}

- (CGFloat)minAmount {
    return 0.85;
}

- (CGFloat)maxAmount {
    return 1.15;
}

- (CGFloat)initialAmount {
    return 1.0;
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setDefaults];
    [filter setValue:@(self.amount) forKey:kCIInputContrastKey];
    return filter;
}

@end

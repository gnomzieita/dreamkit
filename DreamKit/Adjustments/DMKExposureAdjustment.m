//
//  DMKExposureAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/15/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKExposureAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentExposureKey;
}

- (NSString *)title {
    return @"Exposure";
}

- (CGFloat)minAmount {
    return -2.0;
}

- (CGFloat)maxAmount {
    return 2.0;
}

- (CGFloat)initialAmount {
    return 0;
}

- (NSString *)localizeValue:(CGFloat)value {
    NSString *format = @"EV %+.02f";
    return [NSString stringWithFormat:format, value];
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [filter setDefaults];
    [filter setValue:@(self.amount) forKey:kCIInputEVKey];
    return filter;
}



@end

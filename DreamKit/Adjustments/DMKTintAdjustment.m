//
//  DMKTintAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 4/21/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKTintAdjustment


+ (NSString *)adjustmentName {
    return MCAdjustmentTintKey;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleQuadratic;
}

- (NSString *)title {
    return @"Tint";
}

- (CGFloat)minAmount {
    return -100;
}

- (CGFloat)maxAmount {
    return 100;
}

- (CGFloat)initialAmount {
    return 0;
}

- (NSString *)localizeValue:(CGFloat)value {
    static CGFloat minValue = -10;
    static CGFloat maxValue = 10;
    
    CGFloat adjustedValue = (value - self.initialAmount) / ((self.maxAmount - self.minAmount) / (maxValue - minValue));
    
    NSString *format = @"%+.01f";
    
    return [NSString stringWithFormat:format, adjustedValue];
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    [filter setDefaults];
    [filter setValue:[CIVector vectorWithX:6500 Y:0] forKey:@"inputNeutral"];
    [filter setValue:[CIVector vectorWithX:6500 Y:self.amount] forKey:@"inputTargetNeutral"];
    return filter;
}

@end

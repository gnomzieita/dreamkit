//
//  DMKTemperatureAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/31/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKTemperatureAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentTemperatureKey;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleQuadratic;
}

- (NSString *)title {
    return @"Temperature";
}

- (NSString *)localizedTitleKey {
    return @"ADJUSTMENT_TITLE_TEMP";
}

- (CGFloat)minAmount {
    return 2650;
}

- (CGFloat)maxAmount {
    return 10350;
}

- (CGFloat)initialAmount {
    return 6500;
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
    CIVector *vector = [CIVector vectorWithX:self.amount Y:0];
    [filter setValue:[CIVector vectorWithX:6500 Y:0] forKey:@"inputNeutral"];
    [filter setValue:vector forKey:@"inputTargetNeutral"];
    return filter;
}

@end

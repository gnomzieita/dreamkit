//
//  DMKHighlightsAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 4/4/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKHighlightsAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentHighlightsKey;
}

- (NSString *)title {
    return @"Highlights";
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

- (NSString *)localizeValue:(CGFloat)value {
    NSString *format = @"%+.01f";
    return [NSString stringWithFormat:format, value];
}

- (CIFilter *)filter {
    CGFloat amount = 1.0 - (self.amount * 0.07);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    [filter setValue:@(amount) forKey:@"inputHighlightAmount"];

    return filter;
}

@end

//
//  DMKShadowsAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 4/4/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

//
//  DMKHighlightsAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 4/4/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKShadowsAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentShadowsKey;
}

- (NSString *)title {
    return @"Shadows";
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
    CGFloat amount = (self.amount * 0.07);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    [filter setValue:@(amount) forKey:@"inputShadowAmount"];
    return filter;
}

@end

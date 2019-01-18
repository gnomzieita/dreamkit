//
//  DMKVignetteAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/31/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@interface DMKVignetteAdjustment ()

@property (nonatomic, strong) CIFilter *gradientFilter;

@end

@implementation DMKVignetteAdjustment


+ (NSString *)adjustmentName {
    return MCAdjustmentVignetteKey;
}

- (NSString *)title {
    return @"Vignette";
}

- (CGFloat)minAmount {
    return 0.0;
}

- (CGFloat)maxAmount {
    return 3.0;
}

- (CGFloat)initialAmount {
    return 0.0;
}

- (void)setAmount:(CGFloat)amount {
    [super setAmount:amount];
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CIVignette"];
    [filter setDefaults];
    [filter setValue:@(1.0) forKey:kCIInputRadiusKey];
    [filter setValue:@(self.amount) forKey:kCIInputIntensityKey];
    
    return filter;
}

@end

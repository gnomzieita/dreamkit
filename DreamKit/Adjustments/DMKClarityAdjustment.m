//
//  DMKClarityAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/31/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

CGFloat const DMKClarityAdjustmentSharpenMultiplier = 0.009;
CGFloat const DMKClarityAdjustmentVibranceMultiplier = 0.017;

@interface DMKVibranceAdjustment ()

@property (nonatomic, strong) CIFilter *sharpenFilter;

@end

@implementation DMKVibranceAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentVibranceKey;
}

- (NSString *)title {
    return @"Vibrance";
}

- (CGFloat)minAmount {
    return 0;
}

- (CGFloat)maxAmount {
    return 100.0;
}

- (CGFloat)initialAmount {
    return 0;
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CIVibrance"];
    [filter setDefaults];
    [filter setValue:@(self.amount * DMKClarityAdjustmentVibranceMultiplier) forKey:@"inputAmount"];
    
    return filter;
}

//- (CIImage *)applyToImage:(CIImage *)image {
//    CIFilter *filter = self.CIFilter;
//    [filter setValue:image forKey:kCIInputImageKey];
//    
//    image = [filter valueForKey:kCIOutputImageKey];
//    [self.sharpenFilter setValue:image forKey:kCIInputImageKey];
//    return [self.sharpenFilter valueForKey:kCIOutputImageKey];
//}

@end

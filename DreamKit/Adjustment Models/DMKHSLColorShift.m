//
//  DMKHSLColorShift.m
//  MuseCam
//
//  Created by Chris Webb on 4/20/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKHSLColorShift.h"

NSString * const DMKHSLColorShiftHueKey = @"hue";
NSString * const DMKHSLColorShiftSaturationKey = @"saturation";
NSString * const DMKHSLColorShiftLuminanceKey = @"luminance";

@implementation DMKHSLColorShift

- (void)setValuesFromDictionary:(NSDictionary *)dictionary {
    self.hue = [dictionary[DMKHSLColorShiftHueKey] floatValue];
    self.saturation = [dictionary[DMKHSLColorShiftSaturationKey] floatValue];
    self.luminance = [dictionary[DMKHSLColorShiftLuminanceKey] floatValue];
}

- (NSDictionary *)asDictionary {
    return @{
             DMKHSLColorShiftHueKey: @(self.hue),
             DMKHSLColorShiftSaturationKey: @(self.saturation),
             DMKHSLColorShiftLuminanceKey: @(self.luminance)
             };
}

- (NSString *)description {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 20;
    
    return [NSString stringWithFormat:@"<%@, hue: %@, sat: %@, lum: %@]>", [self class], [formatter stringFromNumber:@(self.hue)], [formatter stringFromNumber:@(self.saturation)], [formatter stringFromNumber:@(self.luminance)]];
}

- (BOOL)isEqualToHSLColorShift:(DMKHSLColorShift *)colorShift {
    return self.hue == colorShift.hue && self.saturation == colorShift.saturation && self.luminance == colorShift.luminance;
}

@end

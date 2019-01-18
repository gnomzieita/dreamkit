//
//  DMKPaletteAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 3/8/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"
#import "DMKHSVFilter.h"

@implementation DMKHSVFilter (Convenience)

- (void)mc_setValueFromHSLColorShift:(DMKHSLColorShift *)colorShift forKey:(NSString *)key {
    CGFloat hue = colorShift.hue / 240.0;
    
    CGFloat saturation = colorShift.saturation;
    if (saturation < 0) {
        saturation = saturation / 20.0;
    } else {
        saturation = saturation / 40.0;
    }
    
    CGFloat luminance = colorShift.luminance / 30.0;
    
    CIVector *vector = [CIVector vectorWithX:hue Y:saturation + 1.0 Z:luminance + 1.0];
    [self setValue:vector forKey:key];
}

@end

@implementation DMKPaletteHSLAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentPaletteHSLKey;
}

+ (BOOL)usesSimpleAmountSetting {
    return NO;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleNone;
}

- (NSDictionary<NSString *, DMKHSLColorShift *> *)colorShifts {
    return @{
             @"inputRedShift": self.redShift,
             @"inputOrangeShift": self.orangeShift,
             @"inputYellowShift": self.yellowShift,
             @"inputGreenShift": self.greenShift,
             @"inputAquaShift": self.aquaShift,
             @"inputBlueShift": self.blueShift,
             @"inputPurpleShift": self.purpleShift,
             @"inputMagentaShift": self.magentaShift,
             };
}

- (NSString *)title {
    return @"HSL";
}

- (BOOL)hasInitialAmount {
    return NO;
}

- (CIFilter *)filter {
    DMKHSVFilter *filter = [[DMKHSVFilter alloc] init];
    
    [self enumerateColorShiftsUsingBlock:^(NSString *key, DMKHSLColorShift *colorShift) {
        [filter mc_setValueFromHSLColorShift:colorShift forKey:key];
    }];
    
    return filter;
}

- (void)resetToDefaults {
    _redShift = [[DMKHSLColorShift alloc] init];
    _orangeShift = [[DMKHSLColorShift alloc] init];
    _yellowShift = [[DMKHSLColorShift alloc] init];
    _greenShift = [[DMKHSLColorShift alloc] init];
    _aquaShift = [[DMKHSLColorShift alloc] init];
    _blueShift = [[DMKHSLColorShift alloc] init];
    _purpleShift = [[DMKHSLColorShift alloc] init];
    _magentaShift = [[DMKHSLColorShift alloc] init];
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetToDefaults];
    }
    return self;
}


- (void)enumerateColorShiftsUsingBlock:(void(^)(NSString *key, DMKHSLColorShift *colorShift))block {
    NSDictionary *colorShifts = [self colorShifts];
    [colorShifts enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DMKHSLColorShift * _Nonnull colorShift, BOOL * _Nonnull stop) {
        block(key, colorShift);
    }];
}

- (DMKHSLColorShift *)colorShiftForColor:(DMKHSLColor)hslColor {
    switch (hslColor) {
        case DMKHSLColorRed:
            return self.redShift;
            
        case DMKHSLColorOrange:
            return self.orangeShift;
            
        case DMKHSLColorYellow:
            return self.yellowShift;
            
        case DMKHSLColorGreen:
            return self.greenShift;
            
        case DMKHSLColorAqua:
            return self.aquaShift;
            
        case DMKHSLColorBlue:
            return self.blueShift;
            
        case DMKHSLColorPurple:
            return self.purpleShift;
            
        case DMKHSLColorMagenta:
            return self.magentaShift;
            
        default:
            return nil;
    }
}

- (BOOL)isEqualToAdjustment:(DMKAdjustment *)adjustment {
    if (![super isEqualToAdjustment:adjustment]) {
        return NO;
    }
    
    if (![adjustment isKindOfClass:[DMKPaletteHSLAdjustment class]]) {
        return NO;
    }
    
    DMKPaletteHSLAdjustment *hslAdjustment = (DMKPaletteHSLAdjustment *)adjustment;
    
    return [self.redShift isEqualToHSLColorShift:hslAdjustment.redShift]
        && [self.orangeShift isEqualToHSLColorShift:hslAdjustment.orangeShift]
        && [self.yellowShift isEqualToHSLColorShift:hslAdjustment.yellowShift]
        && [self.greenShift isEqualToHSLColorShift:hslAdjustment.greenShift]
        && [self.aquaShift isEqualToHSLColorShift:hslAdjustment.aquaShift]
        && [self.blueShift isEqualToHSLColorShift:hslAdjustment.blueShift]
        && [self.purpleShift isEqualToHSLColorShift:hslAdjustment.purpleShift]
        && [self.magentaShift isEqualToHSLColorShift:hslAdjustment.magentaShift];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [DMKAdjustment adjustmentFromDictionary:[self dictionaryForSerialization]];
}

#pragma mark - Serialization

- (void)setValues:(id)values {
    [self setValuesFromAttributes:values];
}

- (id)values {
    return [self dictionaryForSerialization][MCAdjustmentDictionaryAttributesKey];
}

- (NSMutableDictionary *)dictionaryForSerialization {
    NSMutableDictionary *dictionary = [super dictionaryForSerialization];
    
    __block NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    [self enumerateColorShiftsUsingBlock:^(NSString *key, DMKHSLColorShift *colorShift) {
        attributes[key] = [colorShift asDictionary];
    }];
    
    dictionary[MCAdjustmentDictionaryAttributesKey] = attributes;
    return dictionary;
}

- (void)setValuesFromAttributes:(NSDictionary *)attributes {
    [self enumerateColorShiftsUsingBlock:^(NSString *key, DMKHSLColorShift *colorShift) {
        [colorShift setValuesFromDictionary:attributes[key]];
    }];
}

- (NSString *)description {
    __block NSString *colorsString = @"";
    
    [self enumerateColorShiftsUsingBlock:^(NSString *key, DMKHSLColorShift *colorShift) {
        NSString *newString = [NSString stringWithFormat:@"%@: %@\n", key, colorShift];
        colorsString = [colorsString stringByAppendingString:newString];
    }];
    
    return [NSString stringWithFormat:@"<%@: %p, color shifts: [%@]>", [self class], self, colorsString];
}

@end

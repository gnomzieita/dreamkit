//
//  MCAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/13/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

NSString * const MCAdjustmentDictionaryNameKey = @"name";
NSString * const MCAdjustmentDictionaryVersionKey = @"version";
NSString * const MCAdjustmentDictionaryAttributesKey = @"attributes";
NSString * const MCAdjustmentDictionaryAmountKey = @"amount";
NSString * const MCAdjustmentDictionaryPoint0Key = @"point0";
NSString * const MCAdjustmentDictionaryPoint1Key = @"point1";
NSString * const MCAdjustmentDictionaryPoint2Key = @"point2";
NSString * const MCAdjustmentDictionaryPoint3Key = @"point3";
NSString * const MCAdjustmentDictionaryPoint4Key = @"point4";

NSString * const MCAdjustmentBrightnessKey = @"MCBrightness";
NSString * const MCAdjustmentExposureKey = @"MCExposure";
NSString * const MCAdjustmentContrastKey = @"MCContrast";
NSString * const MCAdjustmentVibranceKey = @"MCClarity";
NSString * const MCAdjustmentSaturationKey = @"MCSaturation";
NSString * const MCAdjustmentSharpenKey = @"MCSharpen";
NSString * const MCAdjustmentTemperatureKey = @"MCTemperature";
NSString * const MCAdjustmentTintKey = @"MCTint";
NSString * const MCAdjustmentFadeKey = @"MCFade";
NSString * const MCAdjustmentHighlightsKey = @"MCHighlights";
NSString * const MCAdjustmentShadowsKey = @"MCShadows";
NSString * const MCAdjustmentFilmGrainKey = @"MCFilmGrain";
NSString * const MCAdjustmentVignetteKey = @"MCVignette";
NSString * const MCAdjustmentToneCurveKey = @"MCToneCurve";
NSString * const MCAdjustmentRGBCurveKey = @"MCRGBCurve";
NSString * const MCAdjustmentCMYKCurveKey = @"MCCMYKCurve";
NSString * const MCAdjustmentPaletteHSLKey = @"MCPaletteHSL";
NSString * const MCAdjustmentSplitToneKey = @"MCSplitTone";
NSString * const MCAdjustmentStructureKey = @"MCStructure";

@implementation DMKAdjustment

@dynamic localizedTitle;

+ (NSString *)adjustmentName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Adjustment %@ must implement class method adjustmentName", NSStringFromClass([self class])] userInfo:nil];
}

+ (instancetype)adjustmentWithName:(NSString *)name {
    Class adjustmentClass = [self defaultAdjustments][name];
    
    if (adjustmentClass) {
        DMKAdjustment *adjustment = [[adjustmentClass alloc] init];
        return adjustment;
    }
    
    return nil;
}

+ (instancetype)adjustmentFromDictionary:(NSDictionary *)dictionary {
    NSString *adjustmentName = dictionary[MCAdjustmentDictionaryNameKey];
    DMKAdjustment *adjustment = [self adjustmentWithName:adjustmentName];
    if (adjustment == nil) {
        return nil;
    }
    
    [adjustment setValuesFromAttributes:dictionary[MCAdjustmentDictionaryAttributesKey]];
    return adjustment;
}

+ (BOOL)usesSimpleAmountSetting {
    return YES;
}

+ (BOOL)supportsPartialAmount {
    return NO;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleLinear;
}

+ (NSDictionary *)defaultAdjustments {
    static NSDictionary * adjustments = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adjustments = @{
                MCAdjustmentToneCurveKey: [DMKToneCurveAdjustment class],
                MCAdjustmentBrightnessKey: [DMKBrightnessAdjustment class],
                MCAdjustmentRGBCurveKey: [DMKRGBCurveAdjustment class],
                MCAdjustmentCMYKCurveKey: [DMKCMYKCurveAdjustment class],
                MCAdjustmentExposureKey: [DMKExposureAdjustment class],
                MCAdjustmentContrastKey: [DMKContrastAdjustment class],
                MCAdjustmentVibranceKey: [DMKVibranceAdjustment class],
                MCAdjustmentSaturationKey: [DMKSaturationAdjustment class],
                MCAdjustmentSharpenKey: [DMKSharpenAdjustment class],
                MCAdjustmentTemperatureKey: [DMKTemperatureAdjustment class],
                MCAdjustmentTintKey: [DMKTintAdjustment class],
                MCAdjustmentFadeKey: [DMKFadeAdjustment class],
                MCAdjustmentFilmGrainKey: [DMKFilmGrainAdjustment class],
                MCAdjustmentVignetteKey: [DMKVignetteAdjustment class],
                MCAdjustmentPaletteHSLKey: [DMKPaletteHSLAdjustment class],
                MCAdjustmentShadowsKey: [DMKShadowsAdjustment class],
                MCAdjustmentHighlightsKey: [DMKHighlightsAdjustment class],
                MCAdjustmentSplitToneKey: [DMKSplitToneAdjustment class],
                MCAdjustmentStructureKey: [DMKStructureAdjustment class]
                
            };
    });
    return adjustments;
}

+ (NSArray<NSString *> *)adjustmentNamesInApplyOrder {
    static NSArray<NSString *> *adjustmentNames = nil;
    if (adjustmentNames == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DMKAdjustmentApplyOrder" ofType:@"plist"];
        adjustmentNames = [[NSArray alloc] initWithContentsOfFile:path];
        
        NSLog(@"%@", [NSBundle mainBundle]);
        
        if (adjustmentNames == nil) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"DMKAdjustmentApplyOrder.plist was unable to be read" userInfo:nil];
        }
    }
    return adjustmentNames;
}

#pragma - Abstract methods

- (NSString *)adjustmentName {
    return [[self class] adjustmentName];
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetToDefaults];
    }
    
    return self;
}

- (void)resetToDefaults {
    if ([[self class] usesSimpleAmountSetting]) {
        _amount = self.initialAmount;
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Adjustment must override resetToDefaults if not using a simple amount" userInfo:nil];
    }
}

- (instancetype)initWithString:(NSString *)string {
    return [super init];
}

#pragma mark - Public methods

- (void)setPartialAmountForKey:(NSString *)key values:(id<NSCopying>)values {
    
}

- (CIFilter *)filter {
    return nil;
}

- (BOOL)isEqualToAdjustment:(DMKAdjustment *)adjustment {
    
    if (![adjustment isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (![adjustment.adjustmentName isEqualToString:self.adjustmentName]) {
        return NO;
    }
    
    if ([[adjustment class] usesSimpleAmountSetting]) {
        if (adjustment.amount != self.amount) {
            return NO;
        }
        
        if (adjustment.minAmount != self.minAmount) {
            return NO;
        }
        
        if (adjustment.maxAmount != self.maxAmount) {
            return NO;
        }
        
        if (adjustment.initialAmount != self.initialAmount) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)localizedTitle {
    return NSLocalizedString(self.localizedTitleKey, nil);
}

- (NSString *)localizedAmount {
    if ([self class].usesSimpleAmountSetting) {
        return [self localizeValue:self.amount];
    } else {
        return @"—";
    }
}

- (NSString *)localizedTitleKey {
    NSString *title = self.title.uppercaseString;
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return [NSString stringWithFormat:@"ADJUSTMENT_TITLE_%@", title];
}

- (NSString *)localizeValue:(CGFloat)value {
    NSString *format = @"%.02f";
    return [NSString stringWithFormat:format, value];
}

- (BOOL)isWithinSnapRange {
    CGFloat valueWidth = self.maxAmount - self.minAmount;
    CGFloat snapWidth = valueWidth * 0.05;
    CGFloat minSnap = self.initialAmount - snapWidth;
    CGFloat maxSnap = self.initialAmount + snapWidth;
    if (self.amount >= minSnap && self.amount < maxSnap) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasInitialAmount {
    return (self.amount == self.initialAmount);
}

- (id)values {
    return @(self.amount);
}

- (void)setValues:(id)values {
    if ([values isKindOfClass:[NSNumber class]]) {
        self.amount = [(NSNumber *)values doubleValue];
    } else {
        NSLog(@"Invalid value type");
    }
}

- (void)setValuesFromAttributes:(NSDictionary *)attributes {
    if (attributes[MCAdjustmentDictionaryAmountKey]) {
        self.amount = [attributes[MCAdjustmentDictionaryAmountKey] doubleValue];
    }
}

- (CIImage *)applyToImage:(CIImage *)image {
    CIFilter *filter = [self filter];
    if (filter) {
        [filter setValue:image forKey:kCIInputImageKey];
        return [filter valueForKey:kCIOutputImageKey];
    } else {
        return nil;
    }
}

- (NSMutableDictionary *)dictionaryForSerialization {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[MCAdjustmentDictionaryNameKey] = [[self class] adjustmentName];
    dictionary[MCAdjustmentDictionaryVersionKey] = @"1.0";
    dictionary[MCAdjustmentDictionaryAttributesKey] = [[NSMutableDictionary alloc] init];
    
    if ([[self class] usesSimpleAmountSetting]) {
        dictionary[MCAdjustmentDictionaryAttributesKey][MCAdjustmentDictionaryAmountKey] = @(self.amount);
    }
    
    return dictionary;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    DMKAdjustment *newAdjustment = [DMKAdjustment adjustmentWithName:self.adjustmentName];
    newAdjustment.amount = self.amount;
    return newAdjustment;
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, amount: %@ (%f)>", [self class], self, self.localizedAmount, self.amount];
}

- (instancetype)cloneAdjustment {
    NSDictionary *dictionary = [self dictionaryForSerialization];
    
    DMKAdjustment *newAdjustment = [[self class] adjustmentFromDictionary:dictionary];
    return newAdjustment;
}

@end

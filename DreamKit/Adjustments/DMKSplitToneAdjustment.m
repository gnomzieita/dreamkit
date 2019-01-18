//
//  DMKSplitToneAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 5/4/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"
#import "DMKRGBToneCurveFilter.h"

typedef struct {
    float red;
    float green;
    float blue;
} MCSplitToneScale;

static const NSString * MCSplitToneHighlightsColorKey = @"highlightsColor";
static const NSString * MCSplitToneHighlightsAmountKey = @"highlightsAmount";
static const NSString * MCSplitToneShadowsColorKey = @"shadowsColor";
static const NSString * MCSplitToneShadowsAmountKey = @"shadowsAmount";

static const CGFloat MCSplitTonePosition0 = 0;
static const CGFloat MCSplitTonePosition1 = 0.25;
static const CGFloat MCSplitTonePosition2 = 0.5;
static const CGFloat MCSplitTonePosition3 = 0.75;
static const CGFloat MCSplitTonePosition4 = 1.0;

static const MCSplitToneScale MCSplitToneScaleZero = {0, 0, 0};

MCSplitToneScale MCSplitToneScaleMake(CGFloat hue, CGFloat amount) {
    static const CGFloat hueCorrection = 0.78;
    
    MCSplitToneScale multiple = MCSplitToneScaleZero;
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    UIColor *color = [UIColor colorWithHue:hue * hueCorrection saturation:1.0 brightness:1.0 alpha:1.0];
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    multiple.red = amount * red;
    multiple.green = amount * green;
    multiple.blue = amount * blue;
    return multiple;
}

MCSplitToneScale MCSplitToneScaleMakeShadows(CGFloat hue, CGFloat amount) {
    return MCSplitToneScaleMake(hue, amount);
}

MCSplitToneScale MCSplitToneScaleMakeHighlights(CGFloat hue, CGFloat amount) {
    MCSplitToneScale multiplier = MCSplitToneScaleMake(hue, amount);
    
    MCSplitToneScale newMultiplier = multiplier;
    newMultiplier.red = (multiplier.green + multiplier.blue) / 2.0;
    newMultiplier.green = (multiplier.red + multiplier.blue) / 2.0;
    newMultiplier.blue = (multiplier.red + multiplier.green) / 2.0;
    return newMultiplier;
}


@interface CIVector (DMKVectorWithCurveAdjustment)

+ (CIVector *)mc_vectorForToneCurveWithAdjustedShadows:(CGFloat)shadows highlights:(CGFloat)highlights;

@end

@implementation DMKSplitToneAdjustment

+ (BOOL)usesSimpleAmountSetting {
    return NO;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleNone;
}

+ (NSString *)adjustmentName {
    return MCAdjustmentSplitToneKey;
}

- (NSString *)title {
    return @"Split tone";
}

- (NSString *)localizeValue:(CGFloat)value {
    return nil;
}

- (BOOL)hasInitialAmount {
    if (self.highlightsColor == 0 && self.highlightsAmount == 0 && self.shadowsColor == 0 && self.shadowsAmount == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)resetToDefaults {
    self.highlightsColor = 0;
    self.highlightsAmount = 0;
    self.shadowsAmount = 0;
    self.shadowsColor = 0;
}

- (CIImage *)applyToImage:(CIImage *)image {
    
    const CGFloat positions[] = {MCSplitTonePosition0, MCSplitTonePosition1, MCSplitTonePosition2, MCSplitTonePosition3, MCSplitTonePosition4};
    CIVector *positionsVector = [CIVector vectorWithValues:positions count:5];
    
    DMKRGBToneCurveFilter *filter = [[DMKRGBToneCurveFilter alloc] init];
    [filter setValue:image forKey:kCIInputImageKey];
    filter.inputRedPositions = [positionsVector copy];
    filter.inputGreenPositions = [positionsVector copy];
    filter.inputBluePositions = [positionsVector copy];
    
    MCSplitToneScale shadowsScale = MCSplitToneScaleMakeShadows(self.shadowsColor, self.shadowsAmount);
    MCSplitToneScale highlightsScale = MCSplitToneScaleMakeHighlights(self.highlightsColor, self.highlightsAmount);
    
    filter.inputRedValues = [CIVector mc_vectorForToneCurveWithAdjustedShadows:shadowsScale.red highlights:highlightsScale.red];
    filter.inputGreenValues = [CIVector mc_vectorForToneCurveWithAdjustedShadows:shadowsScale.green highlights:highlightsScale.green];
    filter.inputBlueValues = [CIVector mc_vectorForToneCurveWithAdjustedShadows:shadowsScale.blue highlights:highlightsScale.blue];
    
    return filter.outputImage;
}

- (BOOL)isEqualToAdjustment:(DMKAdjustment *)adjustment {
    if (![super isEqualToAdjustment:adjustment]) {
        return NO;
    }
    
    if (![adjustment isKindOfClass:[DMKSplitToneAdjustment class]]) {
        return NO;
    }
    
    DMKSplitToneAdjustment *splitToneAdjustment = (DMKSplitToneAdjustment *)adjustment;
    
    return self.highlightsColor = splitToneAdjustment.highlightsColor &&
        self.highlightsAmount == splitToneAdjustment.highlightsAmount &&
        self.shadowsColor == splitToneAdjustment.shadowsColor &&
        self.shadowsAmount == splitToneAdjustment.shadowsAmount;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [DMKAdjustment adjustmentFromDictionary:[self dictionaryForSerialization]];
}

#pragma mark - Persistence

- (void)setValues:(id)values {
    NSDictionary *dictionary = (NSDictionary *)values;
    if (![values isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.highlightsColor = [dictionary[MCSplitToneHighlightsColorKey] floatValue];
    self.highlightsAmount = [dictionary[MCSplitToneHighlightsAmountKey] floatValue];
    self.shadowsColor = [dictionary[MCSplitToneShadowsColorKey] floatValue];
    self.shadowsAmount = [dictionary[MCSplitToneShadowsAmountKey] floatValue];
}

- (NSMutableDictionary *)dictionaryForSerialization {
    NSMutableDictionary *dictionary = [super dictionaryForSerialization];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    attributes[MCSplitToneHighlightsColorKey] = @(self.highlightsColor);
    attributes[MCSplitToneHighlightsAmountKey] = @(self.highlightsAmount);
    attributes[MCSplitToneShadowsColorKey] = @(self.shadowsColor);
    attributes[MCSplitToneShadowsAmountKey] = @(self.shadowsAmount);
    
    dictionary[MCAdjustmentDictionaryAttributesKey] = attributes;
    return dictionary;
}

- (void)setValuesFromAttributes:(NSDictionary *)attributes {
    [self setValues:attributes];
}

- (id)values {
    return [self dictionaryForSerialization][MCAdjustmentDictionaryAttributesKey];
}


@end

@implementation CIVector (DMKVectorWithCurveAdjustment)

+ (CIVector *)mc_vectorForToneCurveWithAdjustedShadows:(CGFloat)shadows highlights:(CGFloat)highlights {
    static const CGFloat shadowsMax = 0.30;
    static const CGFloat highlightsMax = 0.40;
    
    const CGFloat values[] = {
        MCSplitTonePosition0 + (shadowsMax * shadows),
        MCSplitTonePosition1 + (shadowsMax / 2.0 * shadows),
        MCSplitTonePosition2,
        MCSplitTonePosition3 - (highlightsMax / 2.0 * highlights),
        MCSplitTonePosition4 - (highlightsMax * highlights)
    };
    
    CIVector *valuesVector = [CIVector vectorWithValues:values count:5];
    return valuesVector;
}

@end

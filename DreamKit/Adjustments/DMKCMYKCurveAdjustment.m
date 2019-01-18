//
//  DMKCMYKCurveAdjustment.m
//  DreamKitDemo
//
//  Created by Chris Webb on 2/6/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"
#import "DMKCMYKToneCurveFilter.h"
#import "DMKCMYKCurveColorChannel.h"
#import "DMKAdjustment+DMKCurveHelpers.h"

@implementation DMKCMYKCurveAdjustment

NSString * const DMKCMYKCurveAdjustmentPointsCyanKey = @"cyanPoints";
NSString * const DMKCMYKCurveAdjustmentPointsMagentaKey = @"magentaPoints";
NSString * const DMKCMYKCurveAdjustmentPointsYellowKey = @"yellowPoints";
NSString * const DMKCMYKCurveAdjustmentPointsBlackKey = @"blackPoints";


+ (NSString *)adjustmentName {
    return MCAdjustmentCMYKCurveKey;
}

+ (BOOL)usesSimpleAmountSetting {
    return NO;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleNone;
}

+ (BOOL)supportsPartialAmount {
    return YES;
}

- (NSString *)title {
    return @"CMYK Curve";
}

- (BOOL)hasInitialAmount {
    return NO;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetToDefaults];
    }
    return self;
}

- (CIFilter *)filter {
    DMKCMYKToneCurveFilter *filter = [[DMKCMYKToneCurveFilter alloc] init];
    
    [DMKAdjustment splitVectorsFromPointsArray:self.cyanPoints completionBlock:^(CIVector *positionsVector, CIVector *valuesVector) {
        filter.inputCyanValues = valuesVector;
    }];
    
    [DMKAdjustment splitVectorsFromPointsArray:self.magentaPoints completionBlock:^(CIVector *positionsVector, CIVector *valuesVector) {
        filter.inputMagentaValues = valuesVector;
    }];
    
    [DMKAdjustment splitVectorsFromPointsArray:self.yellowPoints completionBlock:^(CIVector *positionsVector, CIVector *valuesVector) {
        filter.inputYellowValues = valuesVector;
    }];
    
    [DMKAdjustment splitVectorsFromPointsArray:self.blackPoints completionBlock:^(CIVector *positionsVector, CIVector *valuesVector) {
        filter.inputBlackValues = valuesVector;
    }];
    
    return filter;
}

- (void)resetToDefaults {
    NSArray *flatCurvePoints = [DMKAdjustment pointsForFlatCurve];
    
    self.cyanPoints = [flatCurvePoints copy];
    self.magentaPoints = [flatCurvePoints copy];
    self.yellowPoints = [flatCurvePoints copy];
    self.blackPoints = [flatCurvePoints copy];
}

- (void)setValues:(id)values {
    NSDictionary *dictionary = (NSDictionary *)values;
    if (![values isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSDictionary *attributes = dictionary[MCAdjustmentDictionaryAttributesKey];
    
    [self setValuesFromAttributes:attributes];
}

- (void)setPartialAmountForKey:(NSString *)key values:(id<NSCopying>)values {
    [self setValue:values forKey:key];
}

- (BOOL)isEqualToAdjustment:(DMKAdjustment *)adjustment {
    if (![super isEqualToAdjustment:adjustment]) {
        return NO;
    }
    
    if (![adjustment isKindOfClass:[DMKCMYKCurveAdjustment class]]) {
        return NO;
    }
    
    DMKCMYKCurveAdjustment *cmykAdjustment = (DMKCMYKCurveAdjustment *)adjustment;

    if ([self.cyanPoints isEqualToArrayOfPoints:cmykAdjustment.cyanPoints] &&
        [self.magentaPoints isEqualToArrayOfPoints:cmykAdjustment.magentaPoints] &&
        [self.yellowPoints isEqualToArrayOfPoints:cmykAdjustment.yellowPoints] &&
        [self.blackPoints isEqualToArrayOfPoints:cmykAdjustment.blackPoints]) {
        return YES;
    }
    
    return NO;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    DMKCMYKCurveAdjustment *adjustment = (DMKCMYKCurveAdjustment *)[DMKAdjustment adjustmentWithName:self.adjustmentName];
    adjustment.cyanPoints = self.cyanPoints;
    adjustment.magentaPoints = self.magentaPoints;
    adjustment.yellowPoints = self.yellowPoints;
    adjustment.blackPoints = self.blackPoints;
    return adjustment;
}

#pragma mark - Serialization

- (NSMutableDictionary *)dictionaryForSerialization {
    NSMutableDictionary *dictionary = [super dictionaryForSerialization];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    attributes[DMKCMYKCurveAdjustmentPointsCyanKey]   = [DMKAdjustment flattedArrayOfValues:self.cyanPoints];
    attributes[DMKCMYKCurveAdjustmentPointsMagentaKey] = [DMKAdjustment flattedArrayOfValues:self.magentaPoints];
    attributes[DMKCMYKCurveAdjustmentPointsYellowKey]  = [DMKAdjustment flattedArrayOfValues:self.yellowPoints];
    attributes[DMKCMYKCurveAdjustmentPointsBlackKey]  = [DMKAdjustment flattedArrayOfValues:self.blackPoints];
    
    dictionary[MCAdjustmentDictionaryAttributesKey] = attributes;
    return dictionary;
}

- (void)setValuesFromAttributes:(NSDictionary *)attributes {
    self.cyanPoints = [DMKAdjustment unflattedArrayOfValues:attributes[DMKCMYKCurveAdjustmentPointsCyanKey]];
    self.magentaPoints = [DMKAdjustment unflattedArrayOfValues:attributes[DMKCMYKCurveAdjustmentPointsMagentaKey]];
    self.yellowPoints = [DMKAdjustment unflattedArrayOfValues:attributes[DMKCMYKCurveAdjustmentPointsYellowKey]];
    self.blackPoints = [DMKAdjustment unflattedArrayOfValues:attributes[DMKCMYKCurveAdjustmentPointsBlackKey]];
}

- (id)values {
    NSMutableDictionary *valuesDictionary = [self dictionaryForSerialization];
    return valuesDictionary;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, points: [%@]>", [self class], self, [self dictionaryForSerialization]];
}

@end

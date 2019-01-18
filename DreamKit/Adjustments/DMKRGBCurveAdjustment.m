//
//  DMKRGBCurveAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 3/29/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"
#import "DMKRGBToneCurveFilter.h"
#import "DMKAdjustment+DMKCurveHelpers.h"

NSString * const DMKRGBCurveAdjustmentPointsRedKey = @"redPoints";
NSString * const DMKRGBCurveAdjustmentPointsGreenKey = @"greenPoints";
NSString * const DMKRGBCurveAdjustmentPointsBlueKey = @"bluePoints";

@implementation DMKRGBCurveAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentRGBCurveKey;
}

+ (BOOL)usesSimpleAmountSetting {
    return NO;
}

+ (BOOL)supportsPartialAmount {
    return YES;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleNone;
}

- (NSString *)title {
    return @"RGB Curve";
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
    DMKRGBToneCurveFilter *filter = [[DMKRGBToneCurveFilter alloc] init];
    
    [DMKAdjustment splitVectorsFromPointsArray:self.redPoints completionBlock:^(CIVector *positionsVector, CIVector *valuesVector) {
        filter.inputRedPositions = positionsVector;
        filter.inputRedValues = valuesVector;
    }];
    
    [DMKAdjustment splitVectorsFromPointsArray:self.greenPoints completionBlock:^(CIVector *positionsVector, CIVector *valuesVector) {
        filter.inputGreenPositions = positionsVector;
        filter.inputGreenValues = valuesVector;
    }];
    
    [DMKAdjustment splitVectorsFromPointsArray:self.bluePoints completionBlock:^(CIVector *positionsVector, CIVector *valuesVector) {
        filter.inputBluePositions = positionsVector;
        filter.inputBlueValues = valuesVector;
    }];

    return filter;
}

- (void)resetToDefaults {
    NSArray *flatCurvePoints = [DMKAdjustment pointsForFlatCurve];
    
    self.redPoints = [flatCurvePoints copy];
    self.greenPoints = [flatCurvePoints copy];
    self.bluePoints = [flatCurvePoints copy];
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
    
    if (![adjustment isKindOfClass:[DMKRGBCurveAdjustment class]]) {
        return NO;
    }
    
    DMKRGBCurveAdjustment *rgbAdjustment = (DMKRGBCurveAdjustment *)adjustment;
    

    if ([self.redPoints isEqualToArrayOfPoints:rgbAdjustment.redPoints] &&
        [self.greenPoints isEqualToArrayOfPoints:rgbAdjustment.greenPoints] &&
        [self.bluePoints isEqualToArrayOfPoints:rgbAdjustment.bluePoints]) {
        return YES;
    }
    
    return NO;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    DMKRGBCurveAdjustment *newAdjustment = [DMKRGBCurveAdjustment adjustmentWithName:self.adjustmentName];
    newAdjustment.redPoints = [self.redPoints copy];
    newAdjustment.greenPoints = [self.greenPoints copy];
    newAdjustment.bluePoints = [self.bluePoints copy];
    return newAdjustment;
}

#pragma mark - Serialization

- (NSMutableDictionary *)dictionaryForSerialization {
    NSMutableDictionary *dictionary = [super dictionaryForSerialization];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    attributes[DMKRGBCurveAdjustmentPointsRedKey]   = [DMKAdjustment flattedArrayOfValues:self.redPoints];
    attributes[DMKRGBCurveAdjustmentPointsGreenKey] = [DMKAdjustment flattedArrayOfValues:self.greenPoints];
    attributes[DMKRGBCurveAdjustmentPointsBlueKey]  = [DMKAdjustment flattedArrayOfValues:self.bluePoints];
    
    dictionary[MCAdjustmentDictionaryAttributesKey] = attributes;
    return dictionary;
}

- (void)setValuesFromAttributes:(NSDictionary *)attributes {
    self.redPoints = [DMKAdjustment unflattedArrayOfValues:attributes[DMKRGBCurveAdjustmentPointsRedKey]];
    self.greenPoints = [DMKAdjustment unflattedArrayOfValues:attributes[DMKRGBCurveAdjustmentPointsGreenKey]];
    self.bluePoints = [DMKAdjustment unflattedArrayOfValues:attributes[DMKRGBCurveAdjustmentPointsBlueKey]];
}

- (id)values {
    NSMutableDictionary *valuesDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
    return [valuesDictionary copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, points: [%@]>", [self class], self, [self dictionaryForSerialization]];
}

@end

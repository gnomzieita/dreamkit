//
//  DMKCurveAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/15/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

CGFloat const MCAdjustmentCurvePositionPoint0 = 0;
CGFloat const MCAdjustmentCurvePositionPoint1 = 0.25;
CGFloat const MCAdjustmentCurvePositionPoint2 = 0.50;
CGFloat const MCAdjustmentCurvePositionPoint3 = 0.75;
CGFloat const MCAdjustmentCurvePositionPoint4 = 1.0;

@implementation DMKToneCurveAdjustment

+ (BOOL)usesSimpleAmountSetting {
    return NO;
}

+ (MCAdjustmentSimpleAmountScale)simpleAmountScale {
    return MCAdjustmentSimpleAmountScaleNone;
}

+ (NSString *)adjustmentName {
    return MCAdjustmentToneCurveKey;
}

- (NSString *)title {
    return @"RGB Curve";
}

- (NSString *)localizeValue:(CGFloat)value {
    return nil;
}

- (BOOL)hasInitialAmount {
    if (self.point0.y == MCAdjustmentCurvePositionPoint0 && self.point1.y == MCAdjustmentCurvePositionPoint1 && self.point2.y == MCAdjustmentCurvePositionPoint2 && self.point3.y == MCAdjustmentCurvePositionPoint3 && self.point4.y == MCAdjustmentCurvePositionPoint4) {
        return YES;
    } else {
        return NO;
    }
}

- (NSArray<NSValue *> *)points {
    return @[[NSValue valueWithCGPoint:self.point0],
             [NSValue valueWithCGPoint:self.point1],
             [NSValue valueWithCGPoint:self.point2],
             [NSValue valueWithCGPoint:self.point3],
             [NSValue valueWithCGPoint:self.point4]];
}

- (void)setPoints:(NSArray<NSValue *> *)points {
    if (!points) {
        [self resetToDefaults];
        return;
    } else if (points.count != 5) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected array of exactly 5 CGPoints" userInfo:nil];
    } else {
        [points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = [NSString stringWithFormat:@"point%lu", (unsigned long)idx];
            [self setValue:obj forKey:key];
        }];
    }
}

- (CIFilter *)filter {
    CIFilter *filter = [CIFilter filterWithName:@"CIToneCurve"];
    [filter setDefaults];
    [self setCurvePoint:self.point0 atKey:0 forCurveFilter:filter];
    [self setCurvePoint:self.point1 atKey:1 forCurveFilter:filter];
    [self setCurvePoint:self.point2 atKey:2 forCurveFilter:filter];
    [self setCurvePoint:self.point3 atKey:3 forCurveFilter:filter];
    [self setCurvePoint:self.point4 atKey:4 forCurveFilter:filter];
    return filter;
}

- (void)setCurvePoint:(CGPoint)point atKey:(NSUInteger)key forCurveFilter:(CIFilter *)filter {
    NSString *filterInputKey = [NSString stringWithFormat:@"inputPoint%lu", (unsigned long)key];
    [filter setValue:[CIVector vectorWithCGPoint:point] forKey:filterInputKey];
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    
    [self resetToDefaults];
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [DMKAdjustment adjustmentFromDictionary:[self dictionaryForSerialization]];
}

#pragma mark - Public methods

- (void)resetToDefaults {
    [self resetPointsToLinearFunction];
}

- (void)resetPointsToLinearFunction {
    self.point0 = CGPointMake(MCAdjustmentCurvePositionPoint0, MCAdjustmentCurvePositionPoint0);
    self.point1 = CGPointMake(MCAdjustmentCurvePositionPoint1, MCAdjustmentCurvePositionPoint1);
    self.point2 = CGPointMake(MCAdjustmentCurvePositionPoint2, MCAdjustmentCurvePositionPoint2);
    self.point3 = CGPointMake(MCAdjustmentCurvePositionPoint3, MCAdjustmentCurvePositionPoint3);
    self.point4 = CGPointMake(MCAdjustmentCurvePositionPoint4, MCAdjustmentCurvePositionPoint4);
}

- (NSMutableDictionary *)dictionaryForSerialization {
    NSMutableDictionary *dictionary = [super dictionaryForSerialization];
    
    NSMutableDictionary *attributes = dictionary[MCAdjustmentDictionaryAttributesKey];
    
    NSArray<NSValue *> *values = [self values];
    attributes[MCAdjustmentDictionaryPoint0Key] = NSStringFromCGPoint([values[0] CGPointValue]);
    attributes[MCAdjustmentDictionaryPoint1Key] = NSStringFromCGPoint([values[1] CGPointValue]);
    attributes[MCAdjustmentDictionaryPoint2Key] = NSStringFromCGPoint([values[2] CGPointValue]);
    attributes[MCAdjustmentDictionaryPoint3Key] = NSStringFromCGPoint([values[3] CGPointValue]);
    attributes[MCAdjustmentDictionaryPoint4Key] = NSStringFromCGPoint([values[4] CGPointValue]);

    return dictionary;
}

- (void)setValuesFromAttributes:(NSDictionary *)attributes {
    if (![attributes[MCAdjustmentDictionaryPoint0Key] isKindOfClass:[NSString class]]) {
        return;
    }
    
    self.point0 = CGPointFromString(attributes[MCAdjustmentDictionaryPoint0Key]);
    self.point1 = CGPointFromString(attributes[MCAdjustmentDictionaryPoint1Key]);
    self.point2 = CGPointFromString(attributes[MCAdjustmentDictionaryPoint2Key]);
    self.point3 = CGPointFromString(attributes[MCAdjustmentDictionaryPoint3Key]);
    self.point4 = CGPointFromString(attributes[MCAdjustmentDictionaryPoint4Key]);
}

- (id)values {
    NSArray *values = @[[NSValue valueWithCGPoint:self.point0],
                        [NSValue valueWithCGPoint:self.point1],
                        [NSValue valueWithCGPoint:self.point2],
                        [NSValue valueWithCGPoint:self.point3],
                        [NSValue valueWithCGPoint:self.point4]
                        ];
    return values;
}

- (void)setValues:(id)values {
    [self setPoints:values];
}

- (BOOL)isEqualToAdjustment:(DMKToneCurveAdjustment *)adjustment {
    
    if (![super isEqualToAdjustment:adjustment]) {
        return NO;
    }
    
    if (!CGPointEqualToPoint(adjustment.point0, self.point0)) {
        return NO;
    }
    
    if (!CGPointEqualToPoint(adjustment.point1, self.point1)) {
        return NO;
    }
    
    if (!CGPointEqualToPoint(adjustment.point2, self.point2)) {
        return NO;
    }
    
    if (!CGPointEqualToPoint(adjustment.point3, self.point3)) {
        return NO;
    }
    
    if (!CGPointEqualToPoint(adjustment.point4, self.point4)) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Private methods

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, points: [%@]>", [self class], self, [(NSArray *)self.values componentsJoinedByString:@", "]];
}

@end

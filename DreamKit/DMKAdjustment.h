//
//  MCAdjustment.h
//  MuseCam
//
//  Created by Chris Webb on 10/13/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreImage;
@import UIKit;
#import "DMKCurveColorChannel.h"
#import "DMKCMYKCurveColorChannel.h"
#import "DMKHSLColor.h"
#import "DMKHSLColorShift.h"

@class MCColorBalance;

extern NSString * const MCAdjustmentDictionaryNameKey;
extern NSString * const MCAdjustmentDictionaryVersionKey;
extern NSString * const MCAdjustmentDictionaryAttributesKey;
extern NSString * const MCAdjustmentDictionaryAmountKey;
extern NSString * const MCAdjustmentDictionaryPoint0Key;
extern NSString * const MCAdjustmentDictionaryPoint1Key;
extern NSString * const MCAdjustmentDictionaryPoint2Key;
extern NSString * const MCAdjustmentDictionaryPoint3Key;
extern NSString * const MCAdjustmentDictionaryPoint4Key;
extern NSString * const MCAdjustmentDictionaryCyanRedKey;
extern NSString * const MCAdjustmentDictionaryMagentaGreenKey;
extern NSString * const MCAdjustmentDictionaryYellowBlueKey;

extern NSString * const MCAdjustmentBrightnessKey;
extern NSString * const MCAdjustmentExposureKey;
extern NSString * const MCAdjustmentContrastKey;
extern NSString * const MCAdjustmentVibranceKey;
extern NSString * const MCAdjustmentSaturationKey;
extern NSString * const MCAdjustmentSharpenKey;
extern NSString * const MCAdjustmentTemperatureKey;
extern NSString * const MCAdjustmentTintKey;
extern NSString * const MCAdjustmentHighlightsKey;
extern NSString * const MCAdjustmentShadowsKey;
extern NSString * const MCAdjustmentFadeKey;
extern NSString * const MCAdjustmentColorKey;
extern NSString * const MCAdjustmentFilmGrainKey;
extern NSString * const MCAdjustmentVignetteKey;
extern NSString * const MCAdjustmentToneCurveKey;
extern NSString * const MCAdjustmentRGBCurveKey;
extern NSString * const MCAdjustmentCMYKCurveKey;
extern NSString * const MCAdjustmentPaletteHSLKey;
extern NSString * const MCAdjustmentSplitToneKey;
extern NSString * const MCAdjustmentStructureKey;

typedef NS_ENUM(NSInteger, MCAdjustmentSimpleAmountScale) {
    MCAdjustmentSimpleAmountScaleNone,
    MCAdjustmentSimpleAmountScaleLinear,
    MCAdjustmentSimpleAmountScaleQuadratic
};

@interface DMKAdjustment : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *localizedTitleKey;
@property (nonatomic, copy, readonly) NSString *localizedTitle;
@property (nonatomic, copy, readonly) NSString *localizedAmount;

@property (nonatomic, assign, readonly) CGFloat minAmount;
@property (nonatomic, assign, readonly) CGFloat maxAmount;
@property (nonatomic, assign, readonly) CGFloat initialAmount;
@property (nonatomic, assign) CGFloat amount;

+ (NSString *)adjustmentName;
+ (instancetype)adjustmentWithName:(NSString *)name;
+ (instancetype)adjustmentFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)defaultAdjustments;
+ (NSArray<NSString *> *)adjustmentNamesInApplyOrder;
+ (BOOL)usesSimpleAmountSetting;
+ (MCAdjustmentSimpleAmountScale)simpleAmountScale;
+ (BOOL)supportsPartialAmount;

- (instancetype)cloneAdjustment;
- (CIFilter *)filter;
- (void)resetToDefaults;

- (BOOL)isEqualToAdjustment:(DMKAdjustment *)adjustment;

- (NSString *)adjustmentName;
- (instancetype)initWithString:(NSString *)string;
- (void)setValuesFromAttributes:(NSDictionary *)attributes;

- (NSString *)localizeValue:(CGFloat)value;
- (id)values;
- (void)setValues:(id)values;
- (void)setPartialAmountForKey:(NSString *)key values:(id<NSCopying>)values;

- (BOOL)isWithinSnapRange;
- (BOOL)hasInitialAmount;

- (CIImage *)applyToImage:(CIImage *)image;

- (NSMutableDictionary *)dictionaryForSerialization;

@end

@interface DMKBrightnessAdjustment : DMKAdjustment

@end

extern CGFloat const MCAdjustmentCurvePositionPoint0;
extern CGFloat const MCAdjustmentCurvePositionPoint1;
extern CGFloat const MCAdjustmentCurvePositionPoint2;
extern CGFloat const MCAdjustmentCurvePositionPoint3;
extern CGFloat const MCAdjustmentCurvePositionPoint4;

@interface DMKToneCurveAdjustment : DMKAdjustment

@property (nonatomic, assign) CGPoint point0;
@property (nonatomic, assign) CGPoint point1;
@property (nonatomic, assign) CGPoint point2;
@property (nonatomic, assign) CGPoint point3;
@property (nonatomic, assign) CGPoint point4;

- (NSArray<NSValue *> *)points;
- (void)setPoints:(NSArray<NSValue *> *)points;
- (void)resetPointsToLinearFunction;

@end

@interface DMKRGBCurveAdjustment : DMKAdjustment

@property (nonatomic, strong) NSArray<NSValue *> *redPoints;
@property (nonatomic, strong) NSArray<NSValue *> *greenPoints;
@property (nonatomic, strong) NSArray<NSValue *> *bluePoints;

@end

@interface DMKCMYKCurveAdjustment : DMKAdjustment

@property (nonatomic, strong) NSArray<NSValue *> *cyanPoints;
@property (nonatomic, strong) NSArray<NSValue *> *magentaPoints;
@property (nonatomic, strong) NSArray<NSValue *> *yellowPoints;
@property (nonatomic, strong) NSArray<NSValue *> *blackPoints;

@end

@interface DMKPaletteHSLAdjustment : DMKAdjustment

@property (nonatomic, strong, readonly) DMKHSLColorShift *redShift;
@property (nonatomic, strong, readonly) DMKHSLColorShift *orangeShift;
@property (nonatomic, strong, readonly) DMKHSLColorShift *yellowShift;
@property (nonatomic, strong, readonly) DMKHSLColorShift *greenShift;
@property (nonatomic, strong, readonly) DMKHSLColorShift *aquaShift;
@property (nonatomic, strong, readonly) DMKHSLColorShift *blueShift;
@property (nonatomic, strong, readonly) DMKHSLColorShift *purpleShift;
@property (nonatomic, strong, readonly) DMKHSLColorShift *magentaShift;

- (DMKHSLColorShift *)colorShiftForColor:(DMKHSLColor)hslColor;
- (void)enumerateColorShiftsUsingBlock:(void(^)(NSString *key, DMKHSLColorShift *colorShift))block;

@end

@interface DMKSplitToneAdjustment : DMKAdjustment

@property (nonatomic, assign) CGFloat highlightsColor;
@property (nonatomic, assign) CGFloat highlightsAmount;
@property (nonatomic, assign) CGFloat shadowsColor;
@property (nonatomic, assign) CGFloat shadowsAmount;

@end

@interface DMKExposureAdjustment : DMKAdjustment

@end

@interface DMKContrastAdjustment : DMKAdjustment

@end

@interface DMKVibranceAdjustment : DMKAdjustment

@end

@interface DMKSaturationAdjustment : DMKAdjustment

@end

@interface DMKSharpenAdjustment : DMKAdjustment

@end

@interface DMKTemperatureAdjustment : DMKAdjustment

@end

@interface DMKTintAdjustment : DMKAdjustment

@end

@interface DMKHighlightsAdjustment : DMKAdjustment

@end

@interface DMKShadowsAdjustment : DMKAdjustment

@end

@interface DMKFadeAdjustment : DMKAdjustment

@end

@interface DMKFilmGrainAdjustment : DMKAdjustment

@end

@interface DMKVignetteAdjustment : DMKAdjustment

@end

@interface DMKStructureAdjustment : DMKAdjustment

@end


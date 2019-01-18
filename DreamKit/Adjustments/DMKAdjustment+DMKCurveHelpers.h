//
//  DMKAdjustment+DMKCurveHelpers.h
//  DreamKitDemo
//
//  Created by Chris Webb on 2/6/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"
#import "NSArray+DMKComparePointsArray.h"

@interface DMKAdjustment (DMKCurveHelpers)

+ (NSArray<NSValue *> *)pointsForFlatCurve;
+ (NSArray *)flattedArrayOfValues:(NSArray<NSValue *> *)values;
+ (NSArray<NSValue *> *)unflattedArrayOfValues:(NSArray *)values;
+ (void)splitVectorsFromPointsArray:(NSArray<NSValue *> *)pointsArray completionBlock:(void(^)(CIVector *positionsVector, CIVector *valuesVector))completionBlock;

@end

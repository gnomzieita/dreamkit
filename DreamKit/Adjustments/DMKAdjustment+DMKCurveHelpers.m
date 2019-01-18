//
//  DMKAdjustment+DMKCurveHelpers.m
//  DreamKitDemo
//
//  Created by Chris Webb on 2/6/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

#import "DMKAdjustment+DMKCurveHelpers.h"

@implementation DMKAdjustment (DMKCurveHelpers)

+ (NSArray<NSValue *> *)pointsForFlatCurve {
    static NSArray<NSValue *> *initialPoints = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        initialPoints = @[
                          [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                          [NSValue valueWithCGPoint:CGPointMake(0.25, 0.25)],
                          [NSValue valueWithCGPoint:CGPointMake(0.50, 0.50)],
                          [NSValue valueWithCGPoint:CGPointMake(0.75, 0.75)],
                          [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                          ];
    });
    
    return initialPoints;
}

+ (NSArray *)flattedArrayOfValues:(NSArray<NSValue *> *)values {
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:values.count];
    for (NSValue *value in values) {
        [newArray addObject:@([value CGPointValue].y)];
    }
    return [newArray copy];
}

+ (NSArray<NSValue *> *)unflattedArrayOfValues:(NSArray *)values {
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:values.count];
    [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [newArray addObject:[NSValue valueWithCGPoint:CGPointMake(idx / 4.0, [obj floatValue])]];
    }];
    return [newArray copy];
}

+ (void)splitVectorsFromPointsArray:(NSArray<NSValue *> *)pointsArray completionBlock:(void(^)(CIVector *positionsVector, CIVector *valuesVector))completionBlock {
    
    if ([pointsArray count] < 5) {
        NSLog(@"Error loading points");
        return;
    }
    
    const CGFloat positions[] = {
        [pointsArray[0] CGPointValue].x,
        [pointsArray[1] CGPointValue].x,
        [pointsArray[2] CGPointValue].x,
        [pointsArray[3] CGPointValue].x,
        [pointsArray[4] CGPointValue].x
    };
    
    const CGFloat values[] = {
        [pointsArray[0] CGPointValue].y,
        [pointsArray[1] CGPointValue].y,
        [pointsArray[2] CGPointValue].y,
        [pointsArray[3] CGPointValue].y,
        [pointsArray[4] CGPointValue].y
    };
    
    CIVector *positionsVector = [CIVector vectorWithValues:positions count:5];
    CIVector *valuesVector = [CIVector vectorWithValues:values count:5];
    
    completionBlock(positionsVector, valuesVector);
}

@end

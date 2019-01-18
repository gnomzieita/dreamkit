//
//  NSArray+DMKComparePointsArray.m
//  DreamKitDemo
//
//  Created by Chris Webb on 9/27/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

#import "NSArray+DMKComparePointsArray.h"
@import UIKit;

@implementation NSArray (DMKComparePointsArray)

- (BOOL)isEqualToArrayOfPoints:(NSArray<NSValue *> *)points {
    __block BOOL match = YES;
    [self enumerateObjectsUsingBlock:^(NSValue * _Nonnull point, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint oldPoint = [points[idx] CGPointValue];
        CGPoint newPoint = [point CGPointValue];
        match = CGPointEqualToPoint(oldPoint, newPoint);
        if (!match) {
            *stop = YES;
        }
    }];
    return match;
}

@end

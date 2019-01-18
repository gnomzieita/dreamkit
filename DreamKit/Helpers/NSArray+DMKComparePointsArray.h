//
//  NSArray+DMKComparePointsArray.h
//  DreamKitDemo
//
//  Created by Chris Webb on 9/27/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DMKComparePointsArray)

- (BOOL)isEqualToArrayOfPoints:(NSArray<NSValue *> *)points;

@end

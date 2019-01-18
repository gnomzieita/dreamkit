//
//  DMKHSLColorShift.h
//  MuseCam
//
//  Created by Chris Webb on 4/20/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface DMKHSLColorShift : NSObject

@property (assign, nonatomic) CGFloat hue;
@property (assign, nonatomic) CGFloat saturation;
@property (assign, nonatomic) CGFloat luminance;

- (void)setValuesFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)asDictionary;
- (BOOL)isEqualToHSLColorShift:(DMKHSLColorShift *)colorShift;

@end

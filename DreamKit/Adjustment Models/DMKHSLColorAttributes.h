//
//  DMKHSLColorAttributes.h
//  MuseCam
//
//  Created by Chris Webb on 3/13/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMKHSLColor.h"

@interface DMKHSLColorAttributes : NSObject

@property (assign, nonatomic) DMKHSLColor targetColor;
@property (assign, nonatomic) CGFloat hue;
@property (assign, nonatomic) CGFloat saturation;
@property (assign, nonatomic) CGFloat luminance;

/** Returns attributes (hue, saturation, luminance) as a 3D CIVector */
- (CIVector *)attributesAsVector;

- (void)resetToDefaults;

@end

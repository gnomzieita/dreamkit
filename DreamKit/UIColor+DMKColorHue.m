//
//  UIColor+DMKColorHue.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/10/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "UIColor+DMKColorHue.h"

@implementation UIColor (DMKColorHue)

- (CGFloat)dmk_hue {
    CGFloat hue = 0;
    CGFloat saturation = 0;
    CGFloat brightness = 0;
    CGFloat alpha = 0;
    
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    return hue;
}

@end

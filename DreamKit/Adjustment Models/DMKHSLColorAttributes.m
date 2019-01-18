//
//  DMKHSLColorAttributes.m
//  MuseCam
//
//  Created by Chris Webb on 3/13/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKHSLColorAttributes.h"

@implementation DMKHSLColorAttributes

- (CIVector *)attributesAsVector {
    CIVector *vector = [CIVector vectorWithX:self.hue Y:self.saturation + 1.0 Z:self.luminance + 1.0];
    return vector;
}

- (void)resetToDefaults {
    _hue = 0;
    _saturation = 0;
    _luminance = 0;
}

@end

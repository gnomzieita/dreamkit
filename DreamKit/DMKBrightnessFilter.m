//
//  DMKBrightnessFilter.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/5/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKBrightnessFilter.h"

@implementation DMKBrightnessFilter

@synthesize inputImage = _inputImage;
@synthesize inputBrightness = _inputBrightness;

//@synthesize inputImage = inputImage;

static NSUInteger DMKNumberOfPoints = 5;

CIVector * CIVectorForLuminosityCurvePoint(NSUInteger point, CGFloat luminosity) {
    CGFloat offset = point * (1.0 / (DMKNumberOfPoints - 1.0));
    if (luminosity > 0) {
        return [CIVector vectorWithX:offset Y:luminosity + offset * (1.0 - luminosity)];
    } else {
        return [CIVector vectorWithX:offset Y:offset * (1.0 + luminosity)];
    }
}

- (CIImage *)outputImage {
    CGFloat luminosity = [_inputBrightness floatValue];
    
    CIFilter *toneCurveFilter = [CIFilter filterWithName:@"CIToneCurve"
                                     withInputParameters:@{kCIInputImageKey:_inputImage}];

    for (NSUInteger i = 0; i < DMKNumberOfPoints; i++) {
        NSString *key = [NSString stringWithFormat:@"inputPoint%lu", (unsigned long)i];
        CIVector *vector = CIVectorForLuminosityCurvePoint(i, luminosity);
        [toneCurveFilter setValue:vector forKey:key];
    }
    
    return toneCurveFilter.outputImage;
}

@end

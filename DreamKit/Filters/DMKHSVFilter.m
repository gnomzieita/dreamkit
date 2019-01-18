//
//  DMKHSVFilter.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/10/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKHSVFilter.h"
#import "UIColor+DMKColorHue.h"

static NSString * const DMKHSVKernelString = @"\n\
    vec3 rgb2hsv(vec3 c) \
    { \
        vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0); \
        vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g)); \
        vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r)); \
        \
        float d = q.x - min(q.w, q.y); \
        float e = 1.0e-10; \
        return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x); \
    } \
    vec3 hsv2rgb(vec3 c) \
    { \
        vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0); \
        vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www); \
        return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y); \
    } \
    \
    vec3 smoothTreatment(vec3 hsv, float hueEdge0, float hueEdge1, vec3 shiftEdge0, vec3 shiftEdge1) \
    { \
        float smoothedHue = smoothstep(hueEdge0, hueEdge1, hsv.x); \
        float scaledLum = shiftEdge0.z + ((shiftEdge1.z - shiftEdge0.z) * smoothedHue); \
        float hue = hsv.x + (shiftEdge0.x + ((shiftEdge1.x - shiftEdge0.x) * smoothedHue)); \
        float sat = hsv.y * (shiftEdge0.y + ((shiftEdge1.y - shiftEdge0.y) * smoothedHue)); \
        float lum = hsv.z * scaledLum; \
        return vec3(hue, sat, lum); \
    } \
    \
    kernel vec4 kernelFunc(__sample pixel, \
                           vec3 redShift, vec3 orangeShift, vec3 yellowShift, vec3 greenShift, \
                           vec3 aquaShift, vec3 blueShift, vec3 purpleShift, vec3 magentaShift) \
    { \
        vec3 hsv = rgb2hsv(pixel.rgb); \n \
        \
        if (hsv.x < orange){                          hsv = smoothTreatment(hsv, 0.0, orange, redShift, orangeShift);} \n \
        else if (hsv.x >= orange && hsv.x < yellow){  hsv = smoothTreatment(hsv, orange, yellow, orangeShift, yellowShift); } \n \
        else if (hsv.x >= yellow && hsv.x < green){   hsv = smoothTreatment(hsv, yellow, green, yellowShift, greenShift);  } \n \
        else if (hsv.x >= green && hsv.x < aqua){     hsv = smoothTreatment(hsv, green, aqua, greenShift, aquaShift);} \n \
        else if (hsv.x >= aqua && hsv.x < blue){      hsv = smoothTreatment(hsv, aqua, blue, aquaShift, blueShift);} \n \
        else if (hsv.x >= blue && hsv.x < purple){    hsv = smoothTreatment(hsv, blue, purple, blueShift, purpleShift);} \n \
        else if (hsv.x >= purple && hsv.x < magenta){ hsv = smoothTreatment(hsv, purple, magenta, purpleShift, magentaShift);} \n \
        else {                                        hsv = smoothTreatment(hsv, magenta, 1.0, magentaShift, redShift); }; \n \
        \
        return vec4(hsv2rgb(hsv), 1.0); \
    }";

@interface DMKHSVFilter ()

@property (nonatomic, strong, nonnull) CIColorKernel *hsvKernel;

@end

@implementation DMKHSVFilter

- (CIColorKernel *)hsvKernel {
    if (_hsvKernel == nil) {

        CGFloat redHue = 0;
        CGFloat orangeHue = [[UIColor colorWithRed:0.901961 green:0.584314 blue:0.270588 alpha:1] dmk_hue];
        CGFloat yellowHue = [[UIColor colorWithRed:0.901961 green:0.901961 blue:0.270588 alpha:1] dmk_hue];
        CGFloat greenHue = [[UIColor colorWithRed:0.270588 green:0.901961 blue:0.270588 alpha:1] dmk_hue];
        CGFloat aquaHue = [[UIColor colorWithRed:0.270588 green:0.901961 blue:0.901961 alpha:1] dmk_hue];
        CGFloat blueHue = [[UIColor colorWithRed:0.270588 green:0.270588 blue:0.901961 alpha:1] dmk_hue];
        CGFloat purpleHue = [[UIColor colorWithRed:0.584314 green:0.270588 blue:0.901961 alpha:1] dmk_hue];
        CGFloat magentaHue = [[UIColor colorWithRed:0.901961 green:0.270588 blue:0.901961 alpha:1] dmk_hue];
        
        NSString *colorLineFormat = @"#define %@ %f \n";
        
        NSMutableString *colorDefinitions = [NSMutableString string];
        [colorDefinitions appendFormat:colorLineFormat, @"red", redHue];
        [colorDefinitions appendFormat:colorLineFormat, @"orange", orangeHue];
        [colorDefinitions appendFormat:colorLineFormat, @"yellow", yellowHue];
        [colorDefinitions appendFormat:colorLineFormat, @"green", greenHue];
        [colorDefinitions appendFormat:colorLineFormat, @"aqua", aquaHue];
        [colorDefinitions appendFormat:colorLineFormat, @"blue", blueHue];
        [colorDefinitions appendFormat:colorLineFormat, @"purple", purpleHue];
        [colorDefinitions appendFormat:colorLineFormat, @"magenta", magentaHue];
        
        NSString *kernelString = [colorDefinitions stringByAppendingString:DMKHSVKernelString];
        
        _hsvKernel = [CIColorKernel kernelWithString:kernelString];
    }
    return _hsvKernel;
}

- (CIImage *)outputImage {
    if (self.inputImage == nil) {
        return nil;
    }
    
    NSArray<id> *arguments = @[self.inputImage,
                               self.inputRedShift,
                               self.inputOrangeShift,
                               self.inputYellowShift,
                               self.inputGreenShift,
                               self.inputAquaShift,
                               self.inputBlueShift,
                               self.inputPurpleShift,
                               self.inputMagentaShift];
    
    return [self.hsvKernel applyWithExtent:self.inputImage.extent arguments:arguments];
}

@end

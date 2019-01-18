//
//  DMKClarityFilter.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/18/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKClarityFilter.h"

@interface DMKClarityFilter ()

@property (nonatomic, strong) CIColorKernel *colorKernel;

@end

@implementation DMKClarityFilter

static NSString * const DMKClarityKernelString = @"\n\
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
float clampColor(float color) {\
    return max(min(color, 1.0), 0.0);\
}\
vec3 correctContrast(vec3 rgb, float contrast) { \
    float factor = (259.0 / 255.0 * (contrast + 1.0)) / (1.0 * (259.0 / 255.0 - contrast)); \
    vec3 new = rgb; \
    new.r = clampColor(factor * (rgb.r - 0.5) + 0.5); \
    new.g = clampColor(factor * (rgb.g - 0.5) + 0.5); \
    new.b = clampColor(factor * (rgb.b - 0.5) + 0.5); \
    return new; \
} \
\
kernel vec4 kernelFunc(__sample pixel, \
                       float amount) \
{ \
    vec3 hsv = rgb2hsv(pixel.rgb); \n \
    float maxDistance = 0.2; \
    float focus = 0.4; \
\
    float distance = (hsv.z - focus) / focus; \
    float intensity = 0.0;\
    if (distance < maxDistance) { \
        intensity = (maxDistance - distance) / maxDistance;\
    } \
\
    vec3 rgb = correctContrast(pixel.rgb, amount * intensity); \
    return vec4(rgb, 1.0); \
\
}";

/*
 //    vec3 hsv = rgb2hsv(pixel.rgb); \n \
 //    float intensity = 1.0 - abs(0.5 - hsv.z) / 0.5; \n \
 //    hsv.y = hsv.y * (1.0 + amount * intensity); \n \
 //    hsv.z = hsv.z * (1.0 - amount * intensity); \n \
 //    return vec4(hsv2rgb(hsv), 1.0); \*/

- (CIColorKernel *)colorKernel {
    if (_colorKernel == nil) {
        _colorKernel = [CIColorKernel kernelWithString:DMKClarityKernelString];
    }
    return _colorKernel;
}

- (CIImage *)outputImage {
    if (self.inputImage == nil) {
        return nil;
    }
    
    NSArray<id> *arguments = @[self.inputImage,
                               self.amount];

    return [self.colorKernel applyWithExtent:self.inputImage.extent arguments:arguments];
}

@end

//
//  DMKCMYKToneCurveFilter.m
//  DreamKitDemo
//
//  Created by Chris Webb on 2/6/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

#import "DMKCMYKToneCurveFilter.h"

@interface DMKCMYKToneCurveFilter ()

+ (CIColorKernel *)cmykToRGBKernel;
+ (CIColorKernel *)toCyanKernel;
+ (CIColorKernel *)toMagentaKernel;
+ (CIColorKernel *)toYellowKernel;
+ (CIColorKernel *)toBlackKernel;

@end

@implementation DMKCMYKToneCurveFilter

static CIVector * DMKFlatLineCurveVector() {
    CGFloat values[] = {0, 0.25, 0.5, 0.75, 1.0};
    CIVector *defaultVector = [CIVector vectorWithValues:values count:5];
    return defaultVector;
}

static NSString * const DMKRGBToCMYKKernelString = @"\
    vec4 rgbToCMYK(vec3 rgb) \n\
    { \n\
       float k = 1.0 - max(max(rgb.r, rgb.g), rgb.b); \n\
       float c = (1.0 - rgb.r - k) / (1.0 - k);  \n\
       float m = (1.0 - rgb.g - k) / (1.0 - k); \n\
       float y = (1.0 - rgb.b - k) / (1.0 - k); \n\
       return vec4(c, m, y, k);\n\
    }\n";

static NSString * const DMKCMYKToRGBKernelString = @"\
    vec4 cmykToRGB(float c, float m, float y, float k) \n\
    { \n\
        float r = (1.0 - c) * (1.0 - k); \n\
        float g = (1.0 - m) * (1.0 - k); \n\
        float b = (1.0 - y) * (1.0 - k); \n\
        return vec4(r, g, b, 1.0); \n\
    } \n\
    kernel vec4 colorKernel(__sample cyan, __sample magenta, __sample yellow, __sample black) \n\
    { \n\
        return cmykToRGB(cyan.x, magenta.x, yellow.x, black.x);  \n\
    }";

static NSString * const DMKCyanKernelString = @"\
    kernel vec4 colorKernel(__sample pixel) \n\
    { \n\
        return vec4(rgbToCMYK(pixel.rgb).xxx, 1.0); \n\
    }";

static NSString * const DMKMagentaKernelString = @"\
    kernel vec4 colorKernel(__sample pixel) \n\
    { \n\
        return vec4(rgbToCMYK(pixel.rgb).yyy, 1.0); \n\
    }";

static NSString * const DMKYellowKernelString = @"\
    kernel vec4 colorKernel(__sample pixel) \n\
    { \n\
        return vec4(rgbToCMYK(pixel.rgb).zzz, 1.0); \n\
    }";

static NSString * const DMKBlackKernelString = @"\
    kernel vec4 colorKernel(__sample pixel) \n\
    { \n\
        return vec4(rgbToCMYK(pixel.rgb).www, 1.0); \n\
    }";

+ (CIColorKernel *)cmykToRGBKernel {
    static CIColorKernel *kernel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernel = [CIColorKernel kernelWithString:DMKCMYKToRGBKernelString];
    });
    return kernel;
}

+ (CIColorKernel *)toCyanKernel {
    static CIColorKernel *kernel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernel = [CIColorKernel kernelWithString:[DMKRGBToCMYKKernelString stringByAppendingString:DMKCyanKernelString]];
    });
    return kernel;
}

+ (CIColorKernel *)toYellowKernel {
    static CIColorKernel *kernel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernel = [CIColorKernel kernelWithString:[DMKRGBToCMYKKernelString stringByAppendingString:DMKYellowKernelString]];
    });
    return kernel;
}

+ (CIColorKernel *)toMagentaKernel {
    static CIColorKernel *kernel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernel = [CIColorKernel kernelWithString:[DMKRGBToCMYKKernelString stringByAppendingString:DMKMagentaKernelString]];
    });
    return kernel;
}

+ (CIColorKernel *)toBlackKernel {
    static CIColorKernel *kernel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernel = [CIColorKernel kernelWithString:[DMKRGBToCMYKKernelString stringByAppendingString:DMKBlackKernelString]];
    });
    return kernel;
}

+ (CIImage *)applyToneCurveToImage:(CIImage *)image values:(CIVector *)values {
    return [image imageByApplyingFilter:@"CIToneCurve" withInputParameters:[DMKCMYKToneCurveFilter toneCurveParametersFromValues:values]];
}

+ (NSDictionary<NSString *, NSValue *> *)toneCurveParametersFromValues:(CIVector *)values {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    NSString *key;
    CIVector *vector;
    for (NSInteger i = 0; i < 5; i++) {
        key = [NSString stringWithFormat:@"inputPoint%lu", (long)i];
        vector = [CIVector vectorWithX:(i / 4.0) Y:[values valueAtIndex:i]];
        [dictionary setValue:vector forKey:key];
    }
    return dictionary;
}

- (void)setDefaults {
    CIVector *flatCurveValues = DMKFlatLineCurveVector();
    
    _inputCyanValues = flatCurveValues;
    _inputYellowValues = flatCurveValues;
    _inputMagentaValues = flatCurveValues;
    _inputBlackValues = flatCurveValues;
}

- (CIImage *)outputImage {
    if (self.inputImage == nil) {
        return nil;
    }
    
    CGRect extent = self.inputImage.extent;
    
    CIImage *cyanImage = [[DMKCMYKToneCurveFilter toCyanKernel] applyWithExtent:extent arguments:@[self.inputImage]];
    CIImage *magentaImage = [[DMKCMYKToneCurveFilter toMagentaKernel] applyWithExtent:extent arguments:@[self.inputImage]];
    CIImage *yellowImage = [[DMKCMYKToneCurveFilter toYellowKernel] applyWithExtent:extent arguments:@[self.inputImage]];
    CIImage *blackImage = [[DMKCMYKToneCurveFilter toBlackKernel] applyWithExtent:extent arguments:@[self.inputImage]];
    
    cyanImage = [DMKCMYKToneCurveFilter applyToneCurveToImage:cyanImage values:self.inputCyanValues];
    magentaImage = [DMKCMYKToneCurveFilter applyToneCurveToImage:magentaImage values:self.inputMagentaValues];
    yellowImage = [DMKCMYKToneCurveFilter applyToneCurveToImage:yellowImage values:self.inputYellowValues];
    blackImage = [DMKCMYKToneCurveFilter applyToneCurveToImage:blackImage values:self.inputBlackValues];
    
    return [[DMKCMYKToneCurveFilter cmykToRGBKernel] applyWithExtent:extent arguments:@[cyanImage, magentaImage, yellowImage, blackImage]];
}

@end

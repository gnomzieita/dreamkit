//
//  DMKRGBToneCurveFilter.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/10/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKRGBToneCurveFilter.h"
#import "DMKRGBCompositionFilter.h"

@interface DMKRGBToneCurveFilter ()

@property (nonatomic, strong, nonnull) DMKRGBCompositionFilter *rgbCompositionFilter;

@end

@implementation DMKRGBToneCurveFilter

- (DMKRGBCompositionFilter *)rgbCompositionFilter {
    if (_rgbCompositionFilter == nil) {
        _rgbCompositionFilter = [[DMKRGBCompositionFilter alloc] init];
    }
    return _rgbCompositionFilter;
}

static CIVector * DMKFlatLineCurveVector() {
    CGFloat values[] = {0, 0.25, 0.5, 0.75, 1.0};
    CIVector *defaultVector = [CIVector vectorWithValues:values count:5];
    return defaultVector;
}

- (void)setDefaults {
    CIVector *defaultValues = DMKFlatLineCurveVector();
    
    _inputRedValues = defaultValues;
    _inputRedPositions = defaultValues;
    _inputGreenValues = defaultValues;
    _inputGreenPositions = defaultValues;
    _inputBlueValues = defaultValues;
    _inputBluePositions = defaultValues;
}

- (CIImage *)outputImage {
    if (self.inputImage == nil) {
        return nil;
    }
    
    CIImage *redImage = [self.inputImage imageByApplyingFilter:@"CIToneCurve" withInputParameters:[self parametersWithPositions:self.inputRedPositions values:self.inputRedValues]];
    CIImage *greenImage = [self.inputImage imageByApplyingFilter:@"CIToneCurve" withInputParameters:[self parametersWithPositions:self.inputGreenPositions values:self.inputGreenValues]];
    CIImage *blueImage = [self.inputImage imageByApplyingFilter:@"CIToneCurve" withInputParameters:[self parametersWithPositions:self.inputBluePositions values:self.inputBlueValues]];
    
    self.rgbCompositionFilter.inputRedImage = redImage;
    self.rgbCompositionFilter.inputGreenImage = greenImage;
    self.rgbCompositionFilter.inputBlueImage = blueImage;
    return self.rgbCompositionFilter.outputImage;
}

- (NSDictionary<NSString *, NSValue *> *)parametersWithPositions:(CIVector *)positions values:(CIVector *)values {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    NSString *key;
    CIVector *vector;
    for (NSInteger i = 0; i < 5; i++) {
        key = [NSString stringWithFormat:@"inputPoint%lu", (long)i];
        vector = [CIVector vectorWithX:[positions valueAtIndex:i] Y:[values valueAtIndex:i]];
        [dictionary setValue:vector forKey:key];
    }
    return dictionary;
}
                         
@end

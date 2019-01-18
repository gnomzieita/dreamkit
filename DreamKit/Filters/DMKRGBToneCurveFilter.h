//
//  DMKRGBToneCurveFilter.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/10/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface DMKRGBToneCurveFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nonnull) CIVector *inputRedPositions;
@property (nonatomic, strong, nonnull) CIVector *inputRedValues;
@property (nonatomic, strong, nonnull) CIVector *inputGreenPositions;
@property (nonatomic, strong, nonnull) CIVector *inputGreenValues;
@property (nonatomic, strong, nonnull) CIVector *inputBluePositions;
@property (nonatomic, strong, nonnull) CIVector *inputBlueValues;

@end

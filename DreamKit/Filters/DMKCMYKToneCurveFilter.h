//
//  DMKCMYKToneCurveFilter.h
//  DreamKitDemo
//
//  Created by Chris Webb on 2/6/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface DMKCMYKToneCurveFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nonnull) CIVector *inputCyanValues;
@property (nonatomic, strong, nonnull) CIVector *inputMagentaValues;
@property (nonatomic, strong, nonnull) CIVector *inputYellowValues;
@property (nonatomic, strong, nonnull) CIVector *inputBlackValues;

@end

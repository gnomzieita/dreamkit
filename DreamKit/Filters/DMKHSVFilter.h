//
//  DMKHSVFilter.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/10/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface DMKHSVFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nullable) CIVector *inputRedShift;
@property (nonatomic, strong, nullable) CIVector *inputOrangeShift;
@property (nonatomic, strong, nullable) CIVector *inputYellowShift;
@property (nonatomic, strong, nullable) CIVector *inputGreenShift;
@property (nonatomic, strong, nullable) CIVector *inputAquaShift;
@property (nonatomic, strong, nullable) CIVector *inputBlueShift;
@property (nonatomic, strong, nullable) CIVector *inputPurpleShift;
@property (nonatomic, strong, nullable) CIVector *inputMagentaShift;


@end

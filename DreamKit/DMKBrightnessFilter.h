//
//  DMKBrightnessFilter.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/5/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface DMKBrightnessFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nullable) NSNumber *inputBrightness;

@end

//
//  CIImage+DMKTransformImage.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/8/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import "DMKTransformUtilities.h"

@interface CIImage (DMKTransformImage)

- (CIImage *)dmk_imageWithSize:(CGSize)containerSize rotation:(CGFloat)rotation contentMode:(DMKContentMode)contentMode;
- (CIImage *)dmk_imageByCenteringInSize:(CGSize)targetSize contentMode:(DMKContentMode)contentMode;
- (CIImage *)dmk_imageMovedToIdentityOrigin;

@end

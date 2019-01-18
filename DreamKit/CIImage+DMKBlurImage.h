//
//  CIImage+DMKBlurImage.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/8/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIImage (DMKBlurImage)

- (CIImage *)dmk_imageByApplyingBlurRadius:(CGFloat)blurRadius;

@end

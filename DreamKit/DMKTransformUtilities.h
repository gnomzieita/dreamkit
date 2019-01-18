//
//  DMKTransformUtilities.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/8/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIView.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, DMKContentMode) {
    DMKContentModeScaleAspectFit,
    DMKContentModeScaleAspectFill,
    DMKContentModeScaleToFill
};

extern PHImageContentMode dmk_PHImageContentModeFromDMKContentMode(DMKContentMode contentMode);
extern CGAffineTransform dmk_CGAffineTransformToCenterInContainer(CGSize contentSize, CGSize containerSize, DMKContentMode contentMode);
extern CGPoint dmk_CGPointOffsetOfSizeInSize(CGSize contentSize, CGSize containerSize);
extern CGSize dmk_contentScaleForSizeInSize(CGSize contentSize, CGSize containerSize, DMKContentMode contentMode);
extern CGSize dmk_sizeScaleForSizeInSize(CGSize contentSize, CGSize containerSize);

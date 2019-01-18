//
//  DMKTransformUtilities.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/8/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKTransformUtilities.h"

PHImageContentMode dmk_PHImageContentModeFromDMKContentMode(DMKContentMode contentMode) {
    switch (contentMode) {
        case DMKContentModeScaleAspectFit:
            return PHImageContentModeAspectFit;
            
        case DMKContentModeScaleAspectFill:
            return PHImageContentModeAspectFill;
            
        default:
            return PHImageContentModeDefault;
    }
}

CGAffineTransform dmk_CGAffineTransformToCenterInContainer(CGSize contentSize, CGSize containerSize, DMKContentMode contentMode) {
    const CGSize chosenScale = dmk_contentScaleForSizeInSize(contentSize, containerSize, contentMode);
    const CGSize newSize = CGSizeMake(contentSize.width * chosenScale.width, contentSize.height * chosenScale.height);
    CGPoint offset = dmk_CGPointOffsetOfSizeInSize(newSize, containerSize);
    
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(offset.x, offset.y), chosenScale.width, chosenScale.height);
}

CGPoint dmk_CGPointOffsetOfSizeInSize(CGSize contentSize, CGSize containerSize) {
    CGFloat widthDiff = containerSize.width - contentSize.width;
    CGFloat heightDiff = containerSize.height - contentSize.height;
    return CGPointMake(widthDiff / 2.0, heightDiff / 2.0);
}

CGSize dmk_contentScaleForSizeInSize(CGSize contentSize, CGSize containerSize, DMKContentMode contentMode) {
    CGSize sizeScale = dmk_sizeScaleForSizeInSize(contentSize, containerSize);
    
    switch (contentMode) {
        case DMKContentModeScaleAspectFill: {
            CGFloat scale = MAX(sizeScale.width, sizeScale.height);
            return CGSizeMake(scale, scale);
        }
    
        case DMKContentModeScaleAspectFit: {
            CGFloat scale = MIN(sizeScale.width, sizeScale.height);
            return CGSizeMake(scale, scale);
        }
        
        case DMKContentModeScaleToFill: {
            return sizeScale;
        }
    }
}

CGSize dmk_sizeScaleForSizeInSize(CGSize contentSize, CGSize containerSize) {
    CGFloat scaleWidth = containerSize.width / contentSize.width;
    CGFloat scaleHeight = containerSize.height / contentSize.height;
    
    return CGSizeMake(scaleWidth, scaleHeight);
}

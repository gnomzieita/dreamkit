//
//  VideoClipTransition.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/9/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreMedia;

#import "VideoClip.h"

typedef NS_ENUM(NSInteger, VideoTransitionType) {
    VideoTransitionTypeNone,
    VideoTransitionTypeAccordionFold,
    VideoTransitionTypeBarsSwipe,
    VideoTransitionTypeFlash,
    VideoTransitionTypeDissolve,
    VideoTransitionTypeMod,
    VideoTransitionTypePageCurl,
    VideoTransitionTypeSwipe
};

@interface VideoTransition : NSObject

@property (nonatomic, weak) VideoClip *fromClip;
@property (nonatomic, weak) VideoClip *toClip;
@property (nonatomic, assign) VideoTransitionType videoTransitionType;
@property (nonatomic, assign) CMTime duration;

@property (nonatomic, assign, readonly) BOOL isEmptyTransition;

@end

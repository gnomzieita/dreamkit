//
//  VideoClipTransition.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/9/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "VideoTransition.h"

@implementation VideoTransition

- (BOOL)isEmptyTransition {
    if (self.fromClip == nil || self.toClip == nil || self.videoTransitionType == VideoTransitionTypeNone || self.duration.value == 0) {
        return YES;
    }
    
    return NO;
}

@end

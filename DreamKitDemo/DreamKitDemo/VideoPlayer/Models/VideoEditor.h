//
//  Filterer.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/1/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

//@class DMKRecipe;
@class VideoClip;
@class VideoTransition;

@interface VideoEditor : NSObject

// Set these properties before building the composition objects.
@property (nonatomic, copy) NSArray<VideoClip *> *clips;
@property (nonatomic, copy) NSArray<VideoTransition *> *transitions;

- (void)buildCompositionObjectsForPlayback:(BOOL)forPlayback;
- (AVPlayerItem *)playerItem;

@end

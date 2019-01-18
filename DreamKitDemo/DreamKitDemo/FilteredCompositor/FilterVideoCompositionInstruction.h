//
//  FilterVideoCompositionInstruction.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/1/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DMKRecipe.h"
#import "DMKTransformUtilities.h"
#import "VideoTransition.h"
@import AVFoundation;

@class VideoClip;

@interface FilterInstructionAttributes : NSObject

@property (nonatomic, strong) DMKRecipe *recipe;
@property (nonatomic, assign) DMKContentMode contentMode;
@property (nonatomic, assign) CGFloat rotation;

+ (instancetype)filteredInstructionAttributesForVideoClip:(VideoClip *)videoClip;

@end

@interface FilterVideoCompositionInstruction : NSObject <AVVideoCompositionInstruction>

@property (nonatomic, assign) CMPersistentTrackID foregroundTrackID;
@property (nonatomic, strong) FilterInstructionAttributes *foregroundAttributes;

- (instancetype)initWithForegroundTrack:(CMPersistentTrackID)foregroundTrack forTimeRange:(CMTimeRange)timeRange;

@end

@interface TransitioningFilterVideoCompositionInstruction : FilterVideoCompositionInstruction

@property (nonatomic, assign) CMPersistentTrackID backgroundTrackID;
@property (nonatomic, strong) FilterInstructionAttributes *backgroundAttributes;
@property (nonatomic, assign) VideoTransitionType videoTransitionType;

- (instancetype)initWithForegroundTrack:(CMPersistentTrackID)sourceTrack backgroundTrackID:(CMPersistentTrackID)backgroundTrack forTimeRange:(CMTimeRange)timeRange;

@end
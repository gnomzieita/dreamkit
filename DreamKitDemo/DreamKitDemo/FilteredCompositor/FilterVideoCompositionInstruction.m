//
//  FilterVideoCompositionInstruction.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/1/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "FilterVideoCompositionInstruction.h"
#import "VideoClip.h"

@implementation FilterInstructionAttributes

+ (instancetype)filteredInstructionAttributesForVideoClip:(VideoClip *)videoClip {
    FilterInstructionAttributes *attributes = [[self alloc] init];
    attributes.recipe = videoClip.recipe;
    attributes.rotation = videoClip.rotation;
    attributes.contentMode = videoClip.contentMode;
    return attributes;
}

@end

@interface FilterVideoCompositionInstruction ()

- (void)setContainsTweening:(BOOL)containsTweening;
- (void)setRequiredSourceTrackIDs:(NSArray<NSValue *> *)trackIDs;

@end

@implementation FilterVideoCompositionInstruction

@synthesize timeRange = _timeRange;
@synthesize enablePostProcessing = _enablePostProcessing;
@synthesize containsTweening = _containsTweening;
@synthesize requiredSourceTrackIDs = _requiredSourceTrackIDs;
@synthesize passthroughTrackID = _passthroughTrackID;

- (instancetype)initWithForegroundTrack:(CMPersistentTrackID)sourceTrack forTimeRange:(CMTimeRange)timeRange {
    self = [super init];
    if (self) {
        _foregroundTrackID = sourceTrack;
        _requiredSourceTrackIDs = @[@(sourceTrack)];
        _passthroughTrackID = kCMPersistentTrackID_Invalid;
        _timeRange = timeRange;
        _containsTweening = NO;
        _enablePostProcessing = FALSE;
    }
    
    return self;
}

- (void)setContainsTweening:(BOOL)containsTweening {
    _containsTweening = containsTweening;
}

- (void)setRequiredSourceTrackIDs:(NSArray<NSValue *> *)trackIDs {
    _requiredSourceTrackIDs = trackIDs;
}

@end

@implementation TransitioningFilterVideoCompositionInstruction

- (instancetype)initWithForegroundTrack:(CMPersistentTrackID)sourceTrack backgroundTrackID:(CMPersistentTrackID)backgroundTrack forTimeRange:(CMTimeRange)timeRange {
    self = [super initWithForegroundTrack:sourceTrack forTimeRange:timeRange];
    if (self) {
        self.requiredSourceTrackIDs = @[@(sourceTrack), @(backgroundTrack)];
        self.containsTweening = YES;
        _backgroundTrackID = backgroundTrack;
    }
    return self;
}

@end

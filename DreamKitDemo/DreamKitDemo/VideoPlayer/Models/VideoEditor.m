//
//  Filterer.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/1/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "VideoEditor.h"
#import "VideoClip.h"
#import "FilterVideoCompositor.h"
#import "FilterVideoCompositionInstruction.h"
#import "VideoTransition.h"

@interface VideoEditor ()

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;

@end

@implementation VideoEditor

- (VideoTransition *)transitionForAfterClip:(VideoClip *)clip {
    for (VideoTransition *transition in self.transitions) {
        if (transition.fromClip == clip) {
            return transition;
        }
    }
    return nil;
}

- (void)buildCompositionObjectsForPlayback:(BOOL)forPlayback
{
    if ((_clips == nil) || [_clips count] == 0) {
        self.composition = nil;
        self.videoComposition = nil;
        return;
    }
    
    NSUInteger numberOfClips = [self.clips count];
    NSInteger i;

    CGSize videoSize = [[[self.clips firstObject].asset tracksWithMediaType:AVMediaTypeVideo] firstObject].naturalSize;
    AVMutableComposition *composition = [AVMutableComposition composition];
    composition.naturalSize = videoSize;

    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.customVideoCompositorClass = [FilterVideoCompositor class];
    
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    
    compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * numberOfClips);
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * numberOfClips);

    __block NSMutableArray *instructions = [NSMutableArray array];
    
    CMTime nextClipStartTime = kCMTimeZero;
    CMTime beforeTransitionDuration = kCMTimeZero;
    
    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    for (i = 0; i < numberOfClips; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        
        VideoClip *currentClip = _clips[i];
        AVAsset *asset = currentClip.asset;
        
        CMTimeRange timeRangeInAsset = _clips[i].clipTimeRange;
        if (CMTIMERANGE_IS_INVALID(timeRangeInAsset)) {
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        }
        
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        
        AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        if (clipAudioTrack) {
            [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
        }
        
        // Remember the time range in which this clip should pass through.
        // First clip ends with a transition.
        // Second clip begins with a transition.
        // Exclude that transition from the pass through time ranges.
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        
        VideoTransition *transition = [self transitionForAfterClip:currentClip];
        CMTime afterTransitionDuration = kCMTimeZero;
        
        if (transition) {
            afterTransitionDuration = transition.duration;
            for (NSInteger j = i; j <= (i + 1); j++ ) {
                CMTimeRange clipTimeRange = _clips[j].clipTimeRange;
                if (!CMTIMERANGE_IS_EMPTY(clipTimeRange)) {
                    CMTime halfClipDuration = clipTimeRange.duration;
                    halfClipDuration.timescale *= 2; // You can halve a rational by doubling its denominator.
                    afterTransitionDuration = CMTimeMinimum(afterTransitionDuration, halfClipDuration);
                }
            }
        }

        passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, beforeTransitionDuration);
        passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, CMTimeAdd(beforeTransitionDuration, afterTransitionDuration));
        
        // The end of this clip will overlap the start of the next by transitionDuration.
        // (Note: this arithmetic falls apart if timeRangeInAsset.duration < 2 * transitionDuration.)
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
        nextClipStartTime = CMTimeSubtract(nextClipStartTime, afterTransitionDuration);
        
        // Remember the time range for the transition to the next item.
        if (i + 1 < numberOfClips) {
            transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, afterTransitionDuration);
        }
        
        beforeTransitionDuration = afterTransitionDuration;
    }

    // Cycle between "pass through A", "transition from A to B", "pass through B"
    for (i = 0; i < numberOfClips; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets

        FilterVideoCompositionInstruction *videoInstruction = [[FilterVideoCompositionInstruction alloc] initWithForegroundTrack:compositionVideoTracks[alternatingIndex].trackID forTimeRange:passThroughTimeRanges[i]];
        videoInstruction.foregroundAttributes = [FilterInstructionAttributes filteredInstructionAttributesForVideoClip:self.clips[i]];
        [instructions addObject:videoInstruction];
        
        VideoClip *fromClip = self.clips[i];
        VideoTransition *transition = [self transitionForAfterClip:fromClip];
        if (transition && !CMTIMERANGE_IS_EMPTY(transitionTimeRanges[i])) {
            VideoClip *fromClip = self.clips[i];
            VideoClip *toClip = self.clips[i + 1];
            
            TransitioningFilterVideoCompositionInstruction *transitionInstruction = [[TransitioningFilterVideoCompositionInstruction alloc] initWithForegroundTrack:compositionVideoTracks[0].trackID backgroundTrackID:compositionVideoTracks[1].trackID forTimeRange:transitionTimeRanges[i]];
            transitionInstruction.foregroundTrackID = compositionVideoTracks[alternatingIndex].trackID;
            transitionInstruction.foregroundAttributes = [FilterInstructionAttributes filteredInstructionAttributesForVideoClip:fromClip];
    
            transitionInstruction.backgroundTrackID = compositionVideoTracks[1 - alternatingIndex].trackID;
            transitionInstruction.backgroundAttributes = [FilterInstructionAttributes filteredInstructionAttributesForVideoClip:toClip];
            
            transitionInstruction.videoTransitionType = transition.videoTransitionType;
            
            [instructions addObject:transitionInstruction];
        }
    }

    videoComposition.instructions = instructions;

    if (videoComposition) {
        // Every videoComposition needs these properties to be set:
        videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
        videoComposition.renderSize = CGSizeMake(640, 640);
    }
    
    self.composition = composition;
    self.videoComposition = videoComposition;
}

- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString *)presetName {
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:self.composition presetName:presetName];
    session.videoComposition = self.videoComposition;
    return session;
}

- (AVPlayerItem *)playerItem {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.composition];
    playerItem.videoComposition = self.videoComposition;
    
    return playerItem;
}

@end

//
//  ViewController.m
//  DreamKitDemo
//
//  Created by Chris Webb on 7/29/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoPlayerView.h"
#import "VideoEditor.h"
#import "VideoClip.h"
#import "VideoTransition.h"

@interface VideoViewController ()

@property (nonatomic, strong) VideoEditor *editor;
@property (nonatomic, strong) NSArray<VideoClip *>	*clips;
@property (nonatomic, strong) NSArray<VideoTransition *> *transitions;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, weak) IBOutlet VideoPlayerView *playerView;

@property (nonatomic, assign) BOOL seekToZeroBeforePlaying;
@property (nonatomic, assign) BOOL scrubInFlight;
@property (nonatomic, assign) CGFloat lastScrubSliderValue;
@property (nonatomic, assign) CGFloat playRateToRestore;

@end

@implementation VideoViewController

static void * AVCustomEditPlayerViewControllerStatusObservationContext = &AVCustomEditPlayerViewControllerStatusObservationContext;
static void * AVCustomEditPlayerViewControllerRateObservationContext   = &AVCustomEditPlayerViewControllerRateObservationContext;

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _clips = @[];
    _editor = [[VideoEditor alloc] init];
    [self setupEditingAndPlayback];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.player) {
//        _seekToZeroBeforePlaying = NO;
        self.player = [[AVPlayer alloc] init];
//        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:(__bridge void *)(AVCustomEditPlayerViewControllerRateObservationContext)];
        self.playerView.player = self.player;
    }
    
//    [self addTimeObserverToPlayer];

    [self.editor buildCompositionObjectsForPlayback:YES];
    [self synchronizePlayerWithEditor];
}

- (void)setupEditingAndPlayback {
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mov"]]];
    AVURLAsset *asset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video2" ofType:@"mov"]]];

    NSString *adjustmentsRecipe1 = @"[{\"name\":\"MCToneCurve\",\"version\":\"1.0\",\"attributes\":{\"point4\":\"{1, 1}\",\"point1\":\"{0.25, 0.21612903475761414}\",\"point2\":\"{0.5, 0.53451615571975708}\",\"point3\":\"{0.75, 0.78387099504470825}\",\"point0\":\"{0, 0.12354838848114014}\"}},{\"name\":\"MCPaletteHSL\",\"version\":\"1.0\",\"attributes\":{\"inputPurpleShift\":{\"hue\":0,\"luminance\":0,\"saturation\":0},\"inputYellowShift\":{\"hue\":0,\"luminance\":0,\"saturation\":0},\"inputGreenShift\":{\"hue\":0,\"luminance\":0,\"saturation\":0},\"inputBlueShift\":{\"hue\":0,\"luminance\":0,\"saturation\":10.89108943939209},\"inputMagentaShift\":{\"hue\":0,\"luminance\":0,\"saturation\":0},\"inputOrangeShift\":{\"hue\":-2.811501502990723,\"luminance\":0,\"saturation\":17.446540832519531},\"inputRedShift\":{\"hue\":0,\"luminance\":0,\"saturation\":19.320754766464233},\"inputAquaShift\":{\"hue\":6.535947799682617,\"luminance\":0,\"saturation\":4.183006763458252}}},{\"name\":\"MCExposure\",\"version\":\"1.0\",\"attributes\":{\"amount\":0.3}}]";
    
    DMKRecipe *recipe1 = [[DMKRecipe alloc] initWithAdjustmentsJSONString:adjustmentsRecipe1];
    
    NSMutableArray<VideoClip *> *newClips = [[NSMutableArray alloc] init];
    VideoClip *clip1 = [[VideoClip alloc] init];
    clip1.asset = asset1;
    clip1.contentMode = DMKContentModeScaleAspectFit;
    clip1.recipe = recipe1;
    clip1.clipTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 1));
    [newClips addObject:clip1];

    VideoClip *clip2 = [[VideoClip alloc] init];
    clip2.asset = asset2;
    clip2.contentMode = DMKContentModeScaleAspectFit;
    clip2.recipe = recipe1;
    clip2.clipTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(3, 1));
    [newClips addObject:clip2];

    VideoClip *clip3 = [[VideoClip alloc] init];
    clip3.asset = asset1;
    clip3.contentMode = DMKContentModeScaleAspectFill;
    clip3.recipe = recipe1;
    clip3.clipTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(3, 1));
    [newClips addObject:clip3];

    VideoClip *clip4 = [[VideoClip alloc] init];
    clip4.asset = asset2;
    clip4.contentMode = DMKContentModeScaleAspectFill;
    clip4.recipe = recipe1;
    clip4.clipTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(3, 1));
    [newClips addObject:clip4];

    
    NSMutableArray<VideoTransition *> *newTransitions = [[NSMutableArray alloc] init];
    
    VideoTransition *transition1 = [[VideoTransition alloc] init];
    transition1.fromClip = clip1;
    transition1.toClip = clip2;
    transition1.duration = CMTimeMake(1, 1);
    transition1.videoTransitionType = VideoTransitionTypeMod;
    
    [newTransitions addObject:transition1];
    
    VideoTransition *transition2 = [[VideoTransition alloc] init];
    transition2.fromClip = clip2;
    transition2.toClip = clip3;
    transition2.duration = CMTimeMake(1, 2);
    transition2.videoTransitionType = VideoTransitionTypeSwipe;
    [newTransitions addObject:transition2];
    
    VideoTransition *invalidTransition = [[VideoTransition alloc] init];
    invalidTransition.fromClip = clip2;
    invalidTransition.toClip = clip4;
    invalidTransition.duration = CMTimeMake(1, 2);
    invalidTransition.videoTransitionType = VideoTransitionTypeSwipe;
    [newTransitions addObject:invalidTransition];
    
    [self prepareClips:newClips completionHandler:^(NSArray<VideoClip *> *clips) {
        _clips = newClips;
        _transitions = newTransitions;
        
        [self synchronizeWithEditor];
    }];
}

- (void)prepareClips:(NSArray<VideoClip *> *)clips completionHandler:(void(^)(NSArray<VideoClip *> *clips))completionHandler {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    for (VideoClip *clip in clips) {
        dispatch_group_enter(dispatchGroup);
        
        NSArray<NSString *> *assetKeysToLoad = @[@"tracks", @"duration", @"composable"];
        [clip.asset loadValuesAsynchronouslyForKeys:assetKeysToLoad completionHandler:^(){
            
            for (NSString *key in assetKeysToLoad) {
                NSError *error;
                
                if ([clip.asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    NSLog(@"Key value loading failed for key:%@ with error: %@", key, error);
                    goto bail;
                }
            }
            
            if (![clip.asset isComposable]) {
                NSLog(@"Asset is not composable");
                goto bail;
            }

    bail:
            dispatch_group_leave(dispatchGroup);
        }];
    }
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        completionHandler(clips);
    });
}


- (void)synchronizeWithEditor {
    [self synchronizeEditorClipsWithOurClips];
    
    [self.editor buildCompositionObjectsForPlayback:YES];
    
    [self synchronizePlayerWithEditor];
}

- (void)synchronizePlayerWithEditor {
    if (self.player == nil) {
        return;
    }
    
    AVPlayerItem *playerItem = [self.editor playerItem];
    
    if (self.playerItem != playerItem) {
        if (self.playerItem) {
            [self.playerItem removeObserver:self forKeyPath:@"status"];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        }
        
        self.playerItem = playerItem;
        
        if (self.playerItem) {
            if ([self.playerItem respondsToSelector:@selector(setSeekingWaitsForVideoCompositionRendering:)]) {
                self.playerItem.seekingWaitsForVideoCompositionRendering = YES;
            }
            
            // Observe the player item "status" key to determine when it is ready to play
            [self.playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial) context:AVCustomEditPlayerViewControllerStatusObservationContext];
            
            // When the player item has played to its end time we'll set a flag
            // so that the next time the play method is issued the player will
            // be reset to time zero first.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        }
        
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }
}



- (void)synchronizeEditorClipsWithOurClips {
    NSMutableArray<VideoClip *> *validClips = [NSMutableArray arrayWithCapacity:self.clips.count];
    for (VideoClip *clip in self.clips) {
        if (![clip.asset isKindOfClass:[NSNull class]]) {
            [validClips addObject:clip];
        }
    }
    
    // If transitions are broken, it will break the entire composition.
    // We need to verify that the transition's clips are adjacent to each other in the array and that a transition actually has work to do.
    NSMutableArray<VideoTransition *> *validTransitions = [NSMutableArray arrayWithCapacity:self.transitions.count];
    for (VideoTransition *transition in self.transitions) {
        NSInteger fromIndex = [validClips indexOfObject:transition.fromClip];
        NSInteger toIndex = [validClips indexOfObject:transition.toClip];
        
        BOOL clipsAreAdjacent = (fromIndex != NSNotFound) && (toIndex != NSNotFound) && fromIndex == (toIndex - 1);
        
        if (![transition isKindOfClass:[NSNull class]] && !transition.isEmptyTransition && clipsAreAdjacent) {
            [validTransitions addObject:transition];
        }
    }
    
    self.editor.clips = validClips;
    self.editor.transitions = validTransitions;
} 

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == AVCustomEditPlayerViewControllerStatusObservationContext) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            self.player.rate = 1.0;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

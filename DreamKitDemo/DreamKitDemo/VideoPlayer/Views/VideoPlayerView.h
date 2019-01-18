//
//  VideoPlayerView.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/1/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface VideoPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;

@end

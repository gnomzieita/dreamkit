//
//  VideoClip.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/9/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DreamKit.h"
@import AVFoundation;

@interface VideoClip : NSObject

@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, assign) CMTimeRange clipTimeRange;
@property (nonatomic, strong) DMKRecipe *recipe;
@property (nonatomic, assign) DMKContentMode contentMode;
@property (nonatomic, assign) CGFloat rotation;

@end

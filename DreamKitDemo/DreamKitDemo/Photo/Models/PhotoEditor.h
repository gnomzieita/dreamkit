//
//  PhotoEditor.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/18/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DreamKit.h"

@protocol PhotoEditorDelegate;

@interface PhotoEditor : NSObject

@property (nonatomic, weak) id<PhotoEditorDelegate> delegate;

@property (nonatomic, strong) UIImage *inputImage;
@property (nonatomic, strong) DMKRecipe *recipe;

- (void)setInputImage:(UIImage *)image;
- (void)renderImage;

@end

@protocol PhotoEditorDelegate <NSObject>

- (void)photoEditor:(PhotoEditor *)photoEditor didResizeInputImage:(UIImage *)image;
- (void)photoEditor:(PhotoEditor *)photoEditor didRenderImage:(UIImage *)image;

@end
//
//  PhotoViewController.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/17/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoEditor.h"
#import "DreamKit.h"

@interface PhotoViewController () <PhotoEditorDelegate>

@property (nonatomic, strong) PhotoEditor *editor;

@property (nonatomic, weak) IBOutlet UIImageView *originalImageView;
@property (nonatomic, weak) IBOutlet UIImageView *filteredImageView;

@property (nonatomic, assign) BOOL showOriginalImage;

@property (nonatomic, strong) DMKCMYKCurveAdjustment *cmykAdjustment;

@end

@implementation PhotoViewController

- (void)setShowOriginalImage:(BOOL)showOriginalImage {
    _showOriginalImage = showOriginalImage;
    self.originalImageView.hidden = !showOriginalImage;
    self.filteredImageView.hidden = showOriginalImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cmykAdjustment = [[DMKCMYKCurveAdjustment alloc] init];
    
    _cmykAdjustment.cyanPoints = @[
                                      [CIVector vectorWithX:0 Y:0],
                                      [CIVector vectorWithX:0.25 Y:0.25],
                                      [CIVector vectorWithX:0.5 Y:0.5],
                                      [CIVector vectorWithX:0.75 Y:0.5],
                                      [CIVector vectorWithX:1.0 Y:0.7]
                                      ];
    
    DMKMutableRecipe *recipe = [[DMKMutableRecipe alloc] init];
    [recipe addAdjustment:_cmykAdjustment];
    
    _editor = [[PhotoEditor alloc] init];
    _editor.delegate = self;
    _editor.recipe = recipe;
    
    self.showOriginalImage = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_editor setInputImage:self.originalImageView.image];
    [self updatePreview];
}

- (void)updatePreview {
    [self.editor renderImage];
}

#pragma mark - Gesture Recognizers

- (IBAction)handleSliderValueChanged:(UISlider *)slider {
//    self.exposureAdjustment.amount = slider.value;
    [self updatePreview];
}

- (IBAction)handleLongPressRecognizer:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.showOriginalImage = YES;
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            self.showOriginalImage = NO;
            break;
            
        default:
            break;
    }
}

#pragma mark - Photo Editor Delegate

- (void)photoEditor:(PhotoEditor *)photoEditor didResizeInputImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.originalImageView.image = image;
    });
}

- (void)photoEditor:(PhotoEditor *)photoEditor didRenderImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.filteredImageView.image = image;
    });
}

@end

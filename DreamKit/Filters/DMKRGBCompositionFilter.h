//
//  MCRGBChannelComposition.h
//  MuseCam
//
//  Created by Chris Webb on 8/2/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>

extern NSString * _Nonnull const DMKRGBCompositionInputRedImageKey;
extern NSString * _Nonnull const DMKRGBCompositionInputGreenImageKey;
extern NSString * _Nonnull const DMKRGBCompositionInputBlueImageKey;

@interface DMKRGBCompositionFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputRedImage;
@property (nonatomic, strong, nullable) CIImage *inputGreenImage;
@property (nonatomic, strong, nullable) CIImage *inputBlueImage;

@end

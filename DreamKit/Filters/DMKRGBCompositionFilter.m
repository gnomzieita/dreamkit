//
//  MCRGBChannelComposition.m
//  MuseCam
//
//  Created by Chris Webb on 8/2/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKRGBCompositionFilter.h"

NSString * const DMKRGBCompositionInputRedImageKey = @"inputRedImage";
NSString * const DMKRGBCompositionInputGreenImageKey = @"inputGreenImage";
NSString * const DMKRGBCompositionInputBlueImageKey = @"inputBlueImage";

static NSString * const MCRGBCompositionKernel = @"\
    kernel vec4 rgbChannelCompositing(__sample red, __sample green, __sample blue) \n\
    { \n\
        return vec4(red.r, green.g, blue.b, 1.0); \n\
    }";

@interface DMKRGBCompositionFilter ()

@property (nonatomic, strong, nonnull) CIColorKernel *rgbCompositingKernel;

@end

@implementation DMKRGBCompositionFilter

- (CIColorKernel *)rgbChannelCompositingKernel {
    if (_rgbCompositingKernel == nil) {
        _rgbCompositingKernel = [CIColorKernel kernelWithString:MCRGBCompositionKernel];
    }
    return _rgbCompositingKernel;
}

- (NSDictionary *)attributes {
    return @{
             DMKRGBCompositionInputRedImageKey: @{kCIAttributeIdentity: @0,
                                                  kCIAttributeClass: @"CIImage",
                                                  kCIAttributeDisplayName: @"Red Image",
                                                  kCIAttributeType: kCIAttributeTypeImage},
             DMKRGBCompositionInputGreenImageKey: @{kCIAttributeIdentity: @0,
                                                  kCIAttributeClass: @"CIImage",
                                                  kCIAttributeDisplayName: @"Green Image",
                                                  kCIAttributeType: kCIAttributeTypeImage},
             DMKRGBCompositionInputBlueImageKey: @{kCIAttributeIdentity: @0,
                                                  kCIAttributeClass: @"CIImage",
                                                  kCIAttributeDisplayName: @"Blue Image",
                                                  kCIAttributeType: kCIAttributeTypeImage}
             };
}

- (CIImage *)outputImage {
    if (self.inputRedImage == nil || self.inputGreenImage == nil || self.inputBlueImage == nil || self.rgbChannelCompositingKernel == nil) {
        return nil;
    }
    
    CGRect extent = CGRectUnion(CGRectUnion(self.inputRedImage.extent, self.inputBlueImage.extent), self.inputGreenImage.extent);
    
    NSArray *arguments = @[self.inputRedImage, self.inputGreenImage, self.inputBlueImage];
    
    return [self.rgbCompositingKernel applyWithExtent:extent arguments:arguments];
}

@end

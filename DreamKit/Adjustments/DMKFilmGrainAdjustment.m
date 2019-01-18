//
//  DMKGrainAdjustment.m
//  MuseCam
//
//  Created by Chris Webb on 10/15/15.
//  Copyright © 2015 MuseWorks. All rights reserved.
//

#import "DMKAdjustment.h"

@implementation DMKFilmGrainAdjustment

+ (NSString *)adjustmentName {
    return MCAdjustmentFilmGrainKey;
}

- (NSString *)title {
    return @"Film Grain";
}

- (CGFloat)minAmount {
    return 0.0;
}

- (CGFloat)maxAmount {
    return 1.0;
}

- (CGFloat)initialAmount {
    return 0;
}

- (CIFilter *)filter {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use applyToImage" userInfo:nil];
}

- (CIImage *)applyToImage:(CIImage *)image {
    CIFilter *noiseFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
    
    CIVector *whiteVector = [CIVector vectorWithX:0 Y:1 Z:0 W:0];
    CIFilter *matrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [matrixFilter setValue:noiseFilter.outputImage forKey:kCIInputImageKey];
    [matrixFilter setValue:[whiteVector copy] forKey:@"inputRVector"];
    [matrixFilter setValue:[whiteVector copy] forKey:@"inputGVector"];
    [matrixFilter setValue:[whiteVector copy] forKey:@"inputBVector"];
    [matrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:self.amount * 0.6] forKey:@"inputAVector"];
    [matrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBiasVector"];
    
    CIFilter *compositionFilter = [CIFilter filterWithName:@"CISoftLightBlendMode"];
    [compositionFilter setValue:matrixFilter.outputImage forKey:kCIInputImageKey];
    [compositionFilter setValue:image forKey:kCIInputBackgroundImageKey];
    
    return [compositionFilter.outputImage imageByCroppingToRect:image.extent];
}


@end

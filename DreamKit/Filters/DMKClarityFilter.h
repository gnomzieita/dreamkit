//
//  DMKClarityFilter.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/18/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface DMKClarityFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nullable) NSNumber *amount;

@end

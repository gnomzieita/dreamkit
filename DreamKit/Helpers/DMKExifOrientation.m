//
//  DMKExifOrientation.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/11/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKExifOrientation.h"

int dmk_exifOrientationFromUIImageOrientation(UIImageOrientation imageOrientation) {
    switch (imageOrientation) {
        case UIImageOrientationUpMirrored:
            return 2;
            
        case UIImageOrientationLeftMirrored:
            return 3;
            
        case UIImageOrientationLeft:
            return 8;
            
        case UIImageOrientationRight:
            return 6;
            
        case UIImageOrientationDown:
            return 7;
            
        case UIImageOrientationUp:
        default:
            return 1;
    }
}

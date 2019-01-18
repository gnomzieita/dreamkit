//
//  DMKFilteredImageGenerator.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/11/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "DMKRecipe.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMKFilteredImageGenerator : NSObject

+ (instancetype)sharedGenerator;


/**
 Apply recipe asynchronously
 */
- (void)applyRecipe:(DMKRecipe * _Nullable)recipe toImage:(UIImage * _Nullable)image completionHandler:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completionHandler;


/**
 Apply recipe synchronously
 */
- (UIImage * _Nullable)applyRecipe:(DMKRecipe * _Nullable)recipe toImage:(UIImage * _Nullable)image error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

//
//  DMKRecipe.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/2/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreImage;

@class DMKAdjustment;
@class DMKMutableRecipe;

@interface DMKRecipe : NSObject <NSCopying, NSMutableCopying>

@property (copy, nonatomic, readonly) NSDictionary<NSString *, DMKAdjustment *> *adjustments;

- (instancetype)initWithAdjustments:(NSDictionary<NSString *, DMKAdjustment *> *)adjustments NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAdjustmentsJSONString:(NSString *)jsonString;
- (CIImage *)applyAdjustmentsToImage:(CIImage *)image;
- (NSString *)serializeAdjustmentsToJSONString;
- (void)setAdjustmentsFromJSONString:(NSString *)string;

@end

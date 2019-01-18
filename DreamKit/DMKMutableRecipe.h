//
//  DMKMutableRecipe.h
//  DreamKitDemo
//
//  Created by Chris Webb on 8/3/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKRecipe.h"

@interface DMKMutableRecipe : DMKRecipe

- (void)addAdjustment:(DMKAdjustment * _Nonnull)adjustment;
- (void)removeAdjustmentWithName:(NSString * _Nonnull)adjustmentName;
- (void)removeAllAdjustments;

@end

//
//  DMKMutableRecipe.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/3/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKMutableRecipe.h"
#import "DMKAdjustment.h"

@interface DMKMutableRecipe ()

@property (nonatomic, copy) NSMutableDictionary<NSString *, DMKAdjustment *> *adjustments;

@end

@implementation DMKMutableRecipe

@synthesize adjustments = _adjustments;

- (void)setAdjustments:(NSDictionary<NSString *,DMKAdjustment *> *)adjustments {
    _adjustments = [adjustments mutableCopy];
}

- (instancetype)initWithAdjustments:(NSDictionary<NSString *,DMKAdjustment *> *)adjustments {
    self = [super initWithAdjustments:[adjustments mutableCopy]];
    if (!self) {
        return nil;
    }
    
    if (adjustments != nil) {
        self.adjustments = [adjustments mutableCopy];
    } else {
        self.adjustments = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addAdjustment:(DMKAdjustment *)adjustment {
    [self.adjustments setValue:adjustment forKey:adjustment.adjustmentName];
}

- (void)removeAdjustmentWithName:(NSString *)adjustmentName {
    [self.adjustments removeObjectForKey:adjustmentName];
}

- (void)removeAllAdjustments {
    [self.adjustments removeAllObjects];
}

@end

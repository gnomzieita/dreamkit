//
//  DMKRecipe.m
//  DreamKitDemo
//
//  Created by Chris Webb on 8/2/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "DMKRecipe.h"
#import "DMKMutableRecipe.h"
#import "DMKRecipe+Private.h"
#import "DMKAdjustment.h"

@interface DMKRecipe ()

//@property (nonatomic, strong) NSMutableDictionary<NSString *, DMKAdjustment *> *mutableAdjustments;

@property (nonatomic, copy) NSDictionary<NSString *, DMKAdjustment *> *adjustments;

@end

@implementation DMKRecipe

//- (NSDictionary<NSString *, DMKAdjustment *> *)adjustments {
//    return [self.mutableAdjustments mutableCopy];
//}

- (instancetype)init {
    return [self initWithAdjustments:@{}];
}

- (instancetype)initWithAdjustmentsJSONString:(NSString *)jsonString {
    NSDictionary *adjustments = [self adjustmentsFromJSONString:jsonString];
    return [self initWithAdjustments:adjustments];
}

- (instancetype)initWithAdjustments:(NSDictionary<NSString *,DMKAdjustment *> *)adjustments {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.adjustments = adjustments;
    return self;
}

- (void)setAdjustmentsFromJSONString:(NSString *)jsonString {
    NSDictionary *adjustments = [self adjustmentsFromJSONString:jsonString];
    self.adjustments = adjustments;
}

#pragma mark - Image

- (CIImage *)applyAdjustmentsToImage:(CIImage *)image {
    
    __block CIImage *appliedImage = image;
    NSDictionary<NSString *, DMKAdjustment *> *adjustments = [self.adjustments copy];
    
    [[DMKAdjustment adjustmentNamesInApplyOrder] enumerateObjectsUsingBlock:^(NSString * _Nonnull currentAdjustmentName, NSUInteger idx, BOOL * _Nonnull stop) {
        DMKAdjustment *adjustment = adjustments[currentAdjustmentName];
        if (!adjustment) {
            return;
        }
        
        if (![adjustment hasInitialAmount]) {
            appliedImage = [adjustment applyToImage:appliedImage];
        }
        
        if (appliedImage == nil) {
            *stop = YES;
        }
    }];
    
    return appliedImage;
}

//- (NSArray<NSString *> *)adjustmentNamesInApplyOrder {
//    static NSArray<NSString *> *adjustmentNames = nil;
//    if (adjustmentNames == nil) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"DMKAdjustmentApplyOrder" ofType:@"plist"];
//        adjustmentNames = [[NSArray alloc] initWithContentsOfFile:path];
//    }
//    return adjustmentNames;
//}

#pragma mark - Serialization

- (NSDictionary<NSString *, DMKAdjustment *> *)adjustmentsFromJSONString:(NSString *)jsonString {
    NSError *error;
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSArray<NSDictionary *> *serializedDictionaries = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    NSMutableDictionary<NSString *, DMKAdjustment *> *adjustments = [[NSMutableDictionary alloc] initWithCapacity:serializedDictionaries.count];
    
    for (NSDictionary *adjustmentDictionary in serializedDictionaries) {
        DMKAdjustment *adjustment = [DMKAdjustment adjustmentFromDictionary:adjustmentDictionary];
        [adjustments setValue:adjustment forKey:adjustment.adjustmentName];
    }
    
    return [adjustments copy];
}

- (NSArray<NSDictionary *> *)collapseAdjustmentsToArrayOfDictionaries {
    NSMutableArray *adjustmentDictionaries = [[NSMutableArray alloc] initWithCapacity:self.adjustments.count];
    
    [self.adjustments enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, DMKAdjustment *  _Nonnull adjustment, BOOL * _Nonnull stop) {
        [adjustmentDictionaries addObject:[adjustment dictionaryForSerialization]];
    }];
    
    return [adjustmentDictionaries copy];
}

- (NSString *)serializeAdjustmentsToJSONString {
    NSArray<NSDictionary *> *adjustmentDictionaries = [self collapseAdjustmentsToArrayOfDictionaries];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:adjustmentDictionaries
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    NSDictionary<NSString *, DMKAdjustment *> *adjustments = [self.adjustments copy];
    
    NSMutableDictionary<NSString *, DMKAdjustment *> *newAdjustments = [[NSMutableDictionary alloc] initWithCapacity:adjustments.count];
    [adjustments enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DMKAdjustment * _Nonnull adjustment, BOOL * _Nonnull stop) {
        newAdjustments[key] = [adjustment copy];
    }];
    
    return [[DMKRecipe alloc] initWithAdjustments:[newAdjustments copy]];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSDictionary<NSString *, DMKAdjustment *> *adjustments = [self.adjustments copy];
    
    NSMutableDictionary<NSString *, DMKAdjustment *> *newAdjustments = [[NSMutableDictionary alloc] initWithCapacity:adjustments.count];
    [adjustments enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DMKAdjustment * _Nonnull adjustment, BOOL * _Nonnull stop) {
        newAdjustments[key] = [adjustment mutableCopy];
    }];
    
    return [[DMKMutableRecipe alloc] initWithAdjustments:newAdjustments];
}


@end

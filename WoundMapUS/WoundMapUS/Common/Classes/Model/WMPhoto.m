#import "WMPhoto.h"
#import "WMWoundPhoto.h"

@interface WMPhoto ()

// Private interface goes here.

@end


@implementation WMPhoto

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return self.woundPhoto;
}

- (BOOL)requireUpdatesFromCloud
{
    return YES;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMPhotoAttributes.photo,
                                                            @"flagsValue",
                                                            @"originalFlagValue",
                                                            @"scaleValue",
                                                            @"sortRankValue",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPhoto attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPhoto relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPhoto relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

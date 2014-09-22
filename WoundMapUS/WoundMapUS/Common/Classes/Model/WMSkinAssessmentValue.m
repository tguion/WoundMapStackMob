#import "WMSkinAssessmentValue.h"
#import "WMSkinAssessmentGroup.h"

@interface WMSkinAssessmentValue ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentValue

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return self.group;
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue", @"aggregator", @"requireUpdatesFromCloud"]];
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
    if ([[WMSkinAssessmentValue attributeNamesNotToSerialize] containsObject:propertyName] || [[WMSkinAssessmentValue relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMSkinAssessmentValue relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

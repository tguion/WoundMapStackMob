#import "WMConsultingGroup.h"


@interface WMConsultingGroup ()

// Private interface goes here.

@end


@implementation WMConsultingGroup

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"flagsValue"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMConsultingGroup attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMConsultingGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

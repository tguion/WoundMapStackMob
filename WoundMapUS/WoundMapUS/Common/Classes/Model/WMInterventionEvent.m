#import "WMInterventionEvent.h"


@interface WMInterventionEvent ()

// Private interface goes here.

@end


@implementation WMInterventionEvent

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    self.dateEvent = [NSDate date];
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"changeTypeValue"];
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
    if ([[WMInterventionEvent attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMInterventionEvent relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

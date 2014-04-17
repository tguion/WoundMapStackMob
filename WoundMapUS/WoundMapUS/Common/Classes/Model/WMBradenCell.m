#import "WMBradenCell.h"
#import "WMBradenSection.h"

@interface WMBradenCell ()

// Private interface goes here.

@end


@implementation WMBradenCell

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (id)instanceWithBradenSection:(WMBradenSection *)bradenSection
		   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSParameterAssert([bradenSection managedObjectContext] == managedObjectContext);
	WMBradenCell *bradenCell = [WMBradenCell MR_createInContext:managedObjectContext];
	bradenCell.section = bradenSection;
	return bradenCell;
}

- (BOOL)isSelected
{
    return [self.selectedFlag boolValue];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"selectedFlagValue",
                                                            @"valueValue",
                                                            @"isSelected"]];
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
    if ([[WMBradenCell attributeNamesNotToSerialize] containsObject:propertyName] || [[WMBradenCell relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMBradenCell relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

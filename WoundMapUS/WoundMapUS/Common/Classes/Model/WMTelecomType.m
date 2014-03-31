#import "WMTelecomType.h"

NSString * const kTelecomTypeEmailTitle = @"email";

@interface WMTelecomType ()

// Private interface goes here.

@end


@implementation WMTelecomType

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler
{
    NSParameterAssert([WMTelecomType MR_countOfEntitiesWithContext:managedObjectContext] == 0);
    WMTelecomType *telecomType = [WMTelecomType MR_createInContext:managedObjectContext];
    telecomType.sortRankValue = 0;
    telecomType.title = kTelecomTypeEmailTitle;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    if (completionHandler) {
        completionHandler(nil, @[[telecomType objectID]], [WMTelecomType entityName]);
    }
}

+ (NSArray *)sortedTelecomTypes:(NSManagedObjectContext *)managedObjectContext
{
    return [WMTelecomType MR_findAllSortedBy:@"sortRank" ascending:YES inContext:managedObjectContext];
}

+ (WMTelecomType *)telecomTypeForTitle:(NSString *)title
                                create:(BOOL)create
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMTelecomType *telecomType = [WMTelecomType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == telecomType) {
        telecomType = [WMTelecomType MR_createInContext:managedObjectContext];
        telecomType.title = title;
    }
    return telecomType;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)isEmail
{
    return [self.title isEqualToString:kTelecomTypeEmailTitle];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                        @"sortRankValue",
                                        @"isEmail"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMTelecomTypeRelationships.telecoms]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMTelecomType attributeNamesNotToSerialize] containsObject:propertyName] || [[WMTelecomType relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMTelecomType relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

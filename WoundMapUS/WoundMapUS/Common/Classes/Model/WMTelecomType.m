#import "WMTelecomType.h"

NSString * const kTelecomTypeEmailTitle = @"email";

@interface WMTelecomType ()

// Private interface goes here.

@end


@implementation WMTelecomType

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    NSParameterAssert([WMTelecomType MR_countOfEntitiesWithContext:managedObjectContext] == 0);
    NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
    WMTelecomType *telecomType = [WMTelecomType MR_createInContext:managedObjectContext];
    telecomType.sortRankValue = 0;
    telecomType.title = kTelecomTypeEmailTitle;
    [managedObjectContext MR_saveOnlySelfAndWait];
    [objectIDs addObject:[telecomType objectID]];
    telecomType = [WMTelecomType MR_createInContext:managedObjectContext];
    telecomType.sortRankValue = 1;
    telecomType.title = @"telephone";
    [managedObjectContext MR_saveOnlySelfAndWait];
    [objectIDs addObject:[telecomType objectID]];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    if (completionHandler) {
        completionHandler(nil, objectIDs, [WMTelecomType entityName], nil);
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

+ (WMTelecomType *)emailTelecomType:(NSManagedObjectContext *)managedObjectContext
{
    return [WMTelecomType telecomTypeForTitle:kTelecomTypeEmailTitle
                                       create:NO
                         managedObjectContext:managedObjectContext];
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

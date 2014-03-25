#import "WMTelecomType.h"

NSString * const kTelecomTypeEmailTitle = @"email";

@interface WMTelecomType ()

// Private interface goes here.

@end


@implementation WMTelecomType

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert([WMTelecomType MR_countOfEntitiesWithContext:managedObjectContext] == 0);
    WMTelecomType *telecomType = [WMTelecomType MR_createInContext:managedObjectContext];
    telecomType.sortRankValue = 0;
    telecomType.title = kTelecomTypeEmailTitle;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
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

#pragma mar - FatFractal

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"telecoms"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"sortRankValue"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"flagsValue"]) {
        return NO;
    }
    // else
    return YES;
}

@end

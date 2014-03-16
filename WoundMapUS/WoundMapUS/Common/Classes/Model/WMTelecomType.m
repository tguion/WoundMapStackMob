#import "WMTelecomType.h"


@interface WMTelecomType ()

// Private interface goes here.

@end


@implementation WMTelecomType

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert([WMTelecomType MR_countOfEntitiesWithContext:managedObjectContext] == 0);
    WMTelecomType *telecomType = [WMTelecomType MR_createInContext:managedObjectContext];
    telecomType.sortRankValue = 0;
    telecomType.title = @"email";
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

@end

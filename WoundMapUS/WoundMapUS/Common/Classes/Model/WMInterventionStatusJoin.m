#import "WMInterventionStatusJoin.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMInterventionStatusJoin ()

// Private interface goes here.

@end


@implementation WMInterventionStatusJoin

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMInterventionStatusJoin *interventionStatusJoin = [[WMInterventionStatusJoin alloc] initWithEntity:[NSEntityDescription entityForName:@"WMInterventionStatusJoin" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:interventionStatusJoin toPersistentStore:store];
	}
    [interventionStatusJoin setValue:[interventionStatusJoin assignObjectId] forKey:[interventionStatusJoin primaryKeyField]];
	return interventionStatusJoin;
}

+ (WMInterventionStatusJoin *)interventionStatusJoinFromStatus:(WMInterventionStatus *)fromStatus
                                                      toStatus:(WMInterventionStatus *)toStatus
                                                        create:(BOOL)create
                                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    fromStatus = (WMInterventionStatus *)[managedObjectContext objectWithID:[fromStatus objectID]];
    toStatus = (WMInterventionStatus *)[managedObjectContext objectWithID:[toStatus objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMInterventionStatusJoin" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"fromStatus == %@ AND toStatus == %@", fromStatus, toStatus]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMInterventionStatusJoin *interventionStatusJoin = [array lastObject];
    if (create && nil == interventionStatusJoin) {
        interventionStatusJoin = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        interventionStatusJoin.fromStatus = fromStatus;
        interventionStatusJoin.toStatus = toStatus;
    }
    return interventionStatusJoin;
}

@end

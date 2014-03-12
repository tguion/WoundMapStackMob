#import "WMInterventionStatusJoin.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMInterventionStatusJoin ()

// Private interface goes here.

@end


@implementation WMInterventionStatusJoin

+ (WMInterventionStatusJoin *)interventionStatusJoinFromStatus:(WMInterventionStatus *)fromStatus
                                                      toStatus:(WMInterventionStatus *)toStatus
                                                        create:(BOOL)create
                                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    fromStatus = (WMInterventionStatus *)[managedObjectContext objectWithID:[fromStatus objectID]];
    toStatus = (WMInterventionStatus *)[managedObjectContext objectWithID:[toStatus objectID]];
    WMInterventionStatusJoin *interventionStatusJoin = [WMInterventionStatusJoin MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fromStatus == %@ AND toStatus == %@", fromStatus, toStatus]
                                                                                                 inContext:managedObjectContext];
    if (create && nil == interventionStatusJoin) {
        interventionStatusJoin = [WMInterventionStatusJoin MR_createInContext:managedObjectContext];
        interventionStatusJoin.fromStatus = fromStatus;
        interventionStatusJoin.toStatus = toStatus;
    }
    return interventionStatusJoin;
}

@end

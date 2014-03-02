#import "WMCarePlanInterventionEvent.h"
#import "WMCarePlanGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMCarePlanInterventionEvent ()

// Private interface goes here.

@end


@implementation WMCarePlanInterventionEvent

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMCarePlanInterventionEvent *carePlanInterventionEvent = [[WMCarePlanInterventionEvent alloc] initWithEntity:[NSEntityDescription entityForName:@"WMCarePlanInterventionEvent" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:carePlanInterventionEvent toPersistentStore:store];
	}
    [carePlanInterventionEvent setValue:[carePlanInterventionEvent assignObjectId] forKey:[carePlanInterventionEvent primaryKeyField]];
	return carePlanInterventionEvent;
}

+ (WMCarePlanInterventionEvent *)carePlanInterventionEventForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
                                                                changeType:(InterventionEventChangeType)changeType
                                                                      path:(NSString *)path
                                                                     title:(NSString *)title
                                                                 valueFrom:(id)valueFrom
                                                                   valueTo:(id)valueTo
                                                                      type:(WMInterventionEventType *)eventType
                                                               participant:(WMParticipant *)participant
                                                                    create:(BOOL)create
                                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                           persistentStore:(NSPersistentStore *)store
{
    carePlanGroup = (WMCarePlanGroup *)[managedObjectContext objectWithID:[carePlanGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMCarePlanInterventionEvent" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:
                           @"carePlanGroup == %@ AND changeType == %d AND path == %@ AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                           carePlanGroup, changeType, path, title, valueFrom, valueTo, eventType, participant]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMCarePlanInterventionEvent *carePlanInterventionEvent = [array lastObject];
    if (create && nil == carePlanInterventionEvent) {
        carePlanInterventionEvent = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        carePlanInterventionEvent.carePlanGroup = carePlanGroup;
        carePlanInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        carePlanInterventionEvent.path = path;
        carePlanInterventionEvent.title = title;
        carePlanInterventionEvent.valueFrom = valueFrom;
        carePlanInterventionEvent.valueTo = valueTo;
        carePlanInterventionEvent.eventType = eventType;
        carePlanInterventionEvent.participant = participant;
    }
    return carePlanInterventionEvent;
}

@end

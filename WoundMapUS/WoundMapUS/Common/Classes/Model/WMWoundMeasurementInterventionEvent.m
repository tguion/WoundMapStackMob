#import "WMWoundMeasurementInterventionEvent.h"
#import "WMWoundMeasurementGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMWoundMeasurementInterventionEvent ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementInterventionEvent

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurementInterventionEvent *woundMeasurementInterventionEvent = [[WMWoundMeasurementInterventionEvent alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementInterventionEvent" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurementInterventionEvent toPersistentStore:store];
	}
    [woundMeasurementInterventionEvent setValue:[woundMeasurementInterventionEvent assignObjectId] forKey:[woundMeasurementInterventionEvent primaryKeyField]];
	return woundMeasurementInterventionEvent;
}

+ (WMWoundMeasurementInterventionEvent *)woundMeasurementInterventionEventForWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup
                                                                                        changeType:(InterventionEventChangeType)changeType
                                                                                             title:(NSString *)title
                                                                                         valueFrom:(id)valueFrom
                                                                                           valueTo:(id)valueTo
                                                                                              type:(WMInterventionEventType *)eventType
                                                                                       participant:(WMParticipant *)participant
                                                                                            create:(BOOL)create
                                                                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                                                   persistentStore:(NSPersistentStore *)store
{
    woundMeasurementGroup = (WMWoundMeasurementGroup *)[managedObjectContext objectWithID:[woundMeasurementGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementInterventionEvent" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:
                           @"measurementGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                           woundMeasurementGroup, changeType, title, valueFrom, valueTo, eventType, participant]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundMeasurementInterventionEvent *woundMeasurementInterventionEvent = [array lastObject];
    if (create && nil == woundMeasurementInterventionEvent) {
        woundMeasurementInterventionEvent = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundMeasurementInterventionEvent.measurementGroup = woundMeasurementGroup;
        woundMeasurementInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        woundMeasurementInterventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            woundMeasurementInterventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            woundMeasurementInterventionEvent.valueTo = valueTo;
        }
        woundMeasurementInterventionEvent.eventType = eventType;
        woundMeasurementInterventionEvent.participant = participant;
    }
    return woundMeasurementInterventionEvent;
}

@end

#import "WMWoundTreatmentIntEvent.h"
#import "WMWoundTreatmentGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMWoundTreatmentIntEvent ()

// Private interface goes here.

@end


@implementation WMWoundTreatmentIntEvent

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundTreatmentIntEvent *woundTreatmentInterventionEvent = [[WMWoundTreatmentIntEvent alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentIntEvent" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundTreatmentInterventionEvent toPersistentStore:store];
	}
    [woundTreatmentInterventionEvent setValue:[woundTreatmentInterventionEvent assignObjectId] forKey:[woundTreatmentInterventionEvent primaryKeyField]];
	return woundTreatmentInterventionEvent;
}

+ (WMWoundTreatmentIntEvent *)woundTreatmentInterventionEventForWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
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
    woundTreatmentGroup = (WMWoundTreatmentGroup *)[managedObjectContext objectWithID:[woundTreatmentGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentIntEvent" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:
                           @"treatmentGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                           woundTreatmentGroup, changeType, title, valueFrom, valueTo, eventType, participant]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundTreatmentIntEvent *woundTreatmentInterventionEvent = [array lastObject];
    if (create && nil == woundTreatmentInterventionEvent) {
        woundTreatmentInterventionEvent = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundTreatmentInterventionEvent.treatmentGroup = woundTreatmentGroup;
        woundTreatmentInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        woundTreatmentInterventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            woundTreatmentInterventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            woundTreatmentInterventionEvent.valueTo = valueTo;
        }
        woundTreatmentInterventionEvent.eventType = eventType;
        woundTreatmentInterventionEvent.participant = participant;
    }
    return woundTreatmentInterventionEvent;
}

@end

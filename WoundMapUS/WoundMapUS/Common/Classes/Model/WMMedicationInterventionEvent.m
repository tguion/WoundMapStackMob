#import "WMMedicationInterventionEvent.h"
#import "WMMedicationGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMMedicationInterventionEvent ()

// Private interface goes here.

@end


@implementation WMMedicationInterventionEvent

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMMedicationInterventionEvent *medicationInterventionEvent = [[WMMedicationInterventionEvent alloc] initWithEntity:[NSEntityDescription entityForName:@"WMMedicationInterventionEvent" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:medicationInterventionEvent toPersistentStore:store];
	}
    [medicationInterventionEvent setValue:[medicationInterventionEvent assignObjectId] forKey:[medicationInterventionEvent primaryKeyField]];
	return medicationInterventionEvent;
}

+ (WMMedicationInterventionEvent *)medicationInterventionEventForMedicationGroup:(WMMedicationGroup *)medicationGroup
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
    medicationGroup = (WMMedicationGroup *)[managedObjectContext objectWithID:[medicationGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMMedicationInterventionEvent" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:
                           @"medicationGroup == %@ AND changeType == %d AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                           medicationGroup, changeType, valueFrom, valueTo, eventType, participant]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMMedicationInterventionEvent *medicationInterventionEvent = [array lastObject];
    // if we add, then remove, we need to look at the objectID to see if it's new
    if (create && (nil == medicationInterventionEvent || [[medicationInterventionEvent objectID] isTemporaryID])) {
        medicationInterventionEvent = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        medicationInterventionEvent.medicationGroup = medicationGroup;
        medicationInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        medicationInterventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            medicationInterventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            medicationInterventionEvent.valueTo = valueTo;
        }
        medicationInterventionEvent.eventType = eventType;
        medicationInterventionEvent.participant = participant;
    }
    return medicationInterventionEvent;
}

@end

#import "WMMedicationInterventionEvent.h"
#import "WMMedicationGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMMedicationInterventionEvent ()

// Private interface goes here.

@end


@implementation WMMedicationInterventionEvent

+ (WMMedicationInterventionEvent *)medicationInterventionEventForMedicationGroup:(WMMedicationGroup *)medicationGroup
                                                                      changeType:(InterventionEventChangeType)changeType
                                                                           title:(NSString *)title
                                                                       valueFrom:(id)valueFrom
                                                                         valueTo:(id)valueTo
                                                                            type:(WMInterventionEventType *)eventType
                                                                     participant:(WMParticipant *)participant
                                                                          create:(BOOL)create
                                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    medicationGroup = (WMMedicationGroup *)[managedObjectContext objectWithID:[medicationGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    WMMedicationInterventionEvent *medicationInterventionEvent = [WMMedicationInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                                                           @"medicationGroup == %@ AND changeType == %d AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                                                           medicationGroup, changeType, valueFrom, valueTo, eventType, participant]
                                                                                                                inContext:managedObjectContext];
    if (create && nil == medicationInterventionEvent) {
        medicationInterventionEvent = [WMMedicationInterventionEvent MR_createInContext:managedObjectContext];
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

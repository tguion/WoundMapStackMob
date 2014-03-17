#import "WMWoundTreatmentIntEvent.h"
#import "WMWoundTreatmentGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMWoundTreatmentIntEvent ()

// Private interface goes here.

@end


@implementation WMWoundTreatmentIntEvent

+ (WMWoundTreatmentIntEvent *)woundTreatmentInterventionEventForWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
                                                                                  changeType:(InterventionEventChangeType)changeType
                                                                                       title:(NSString *)title
                                                                                   valueFrom:(id)valueFrom
                                                                                     valueTo:(id)valueTo
                                                                                        type:(WMInterventionEventType *)eventType
                                                                                 participant:(WMParticipant *)participant
                                                                                      create:(BOOL)create
                                                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundTreatmentIntEvent *woundTreatmentInterventionEvent = [WMWoundTreatmentIntEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                                                     @"treatmentGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                                                     woundTreatmentGroup, changeType, title, valueFrom, valueTo, eventType, participant] inContext:managedObjectContext];
    if (create && nil == woundTreatmentInterventionEvent) {
        woundTreatmentInterventionEvent = [WMWoundTreatmentIntEvent MR_createInContext:managedObjectContext];
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

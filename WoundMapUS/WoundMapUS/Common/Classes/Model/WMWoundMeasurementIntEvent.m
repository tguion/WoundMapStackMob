#import "WMWoundMeasurementIntEvent.h"
#import "WMWoundMeasurementGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMWoundMeasurementIntEvent ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementIntEvent

+ (WMWoundMeasurementIntEvent *)woundMeasurementInterventionEventForWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup
                                                                                        changeType:(InterventionEventChangeType)changeType
                                                                                             title:(NSString *)title
                                                                                         valueFrom:(id)valueFrom
                                                                                           valueTo:(id)valueTo
                                                                                              type:(WMInterventionEventType *)eventType
                                                                                       participant:(WMParticipant *)participant
                                                                                            create:(BOOL)create
                                                                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert([woundMeasurementGroup managedObjectContext] == managedObjectContext);
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    if (nil != eventType) {
        NSParameterAssert([eventType managedObjectContext] == managedObjectContext);
    }
    WMWoundMeasurementIntEvent *woundMeasurementInterventionEvent = [WMWoundMeasurementIntEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                                                           @"measurementGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                                                           woundMeasurementGroup, changeType, title, valueFrom, valueTo, eventType, participant]
                                                                                                                inContext:managedObjectContext];
    if (create && nil == woundMeasurementInterventionEvent) {
        woundMeasurementInterventionEvent = [WMWoundMeasurementIntEvent MR_createInContext:managedObjectContext];
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

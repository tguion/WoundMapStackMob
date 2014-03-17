#import "WMCarePlanInterventionEvent.h"
#import "WMCarePlanGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMCarePlanInterventionEvent ()

// Private interface goes here.

@end


@implementation WMCarePlanInterventionEvent

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
{
    carePlanGroup = (WMCarePlanGroup *)[managedObjectContext objectWithID:[carePlanGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    WMCarePlanInterventionEvent *carePlanInterventionEvent = [WMCarePlanInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                                                     @"carePlanGroup == %@ AND changeType == %d AND path == %@ AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                                                     carePlanGroup, changeType, path, title, valueFrom, valueTo, eventType, participant]
                                                                                                          inContext:managedObjectContext];
    if (create && nil == carePlanInterventionEvent) {
        carePlanInterventionEvent = [WMCarePlanInterventionEvent MR_createInContext:managedObjectContext];
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

#import "WMDeviceInterventionEvent.h"
#import "WMDeviceGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMDeviceInterventionEvent ()

// Private interface goes here.

@end


@implementation WMDeviceInterventionEvent

+ (WMDeviceInterventionEvent *)deviceInterventionEventForDeviceGroup:(WMDeviceGroup *)deviceGroup
                                                          changeType:(InterventionEventChangeType)changeType
                                                               title:(NSString *)title
                                                           valueFrom:(id)valueFrom
                                                             valueTo:(id)valueTo
                                                                type:(WMInterventionEventType *)eventType
                                                         participant:(WMParticipant *)participant
                                                              create:(BOOL)create
                                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    deviceGroup = (WMDeviceGroup *)[managedObjectContext objectWithID:[deviceGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    WMDeviceInterventionEvent *deviceInterventionEvent = [WMDeviceInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                                               @"deviceGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                                               deviceGroup, changeType, title, valueFrom, valueTo, eventType, participant]
                                                                                                    inContext:managedObjectContext];
    if (create && nil == deviceInterventionEvent) {
        deviceInterventionEvent = [WMDeviceInterventionEvent MR_createInContext:managedObjectContext];
        deviceInterventionEvent.deviceGroup = deviceGroup;
        deviceInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        deviceInterventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            deviceInterventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            deviceInterventionEvent.valueTo = valueTo;
        }
        deviceInterventionEvent.eventType = eventType;
        deviceInterventionEvent.participant = participant;
    }
    return deviceInterventionEvent;
}

@end

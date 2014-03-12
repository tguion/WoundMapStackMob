#import "_WMDeviceInterventionEvent.h"
#import "WMInterventionEventType.h"

@interface WMDeviceInterventionEvent : _WMDeviceInterventionEvent {}

+ (WMDeviceInterventionEvent *)deviceInterventionEventForDeviceGroup:(WMDeviceGroup *)deviceGroup
                                                          changeType:(InterventionEventChangeType)changeType
                                                               title:(NSString *)title
                                                           valueFrom:(id)valueFrom
                                                             valueTo:(id)valueTo
                                                                type:(WMInterventionEventType *)eventType
                                                         participant:(WMParticipant *)participant
                                                              create:(BOOL)create
                                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

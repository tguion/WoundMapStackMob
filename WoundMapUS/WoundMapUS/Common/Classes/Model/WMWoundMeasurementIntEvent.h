#import "_WMWoundMeasurementIntEvent.h"
#import "WMInterventionEventType.h"

@interface WMWoundMeasurementIntEvent : _WMWoundMeasurementIntEvent {}

+ (WMWoundMeasurementIntEvent *)woundMeasurementInterventionEventForWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup
                                                                               changeType:(InterventionEventChangeType)changeType
                                                                                    title:(NSString *)title
                                                                                valueFrom:(id)valueFrom
                                                                                  valueTo:(id)valueTo
                                                                                     type:(WMInterventionEventType *)eventType
                                                                              participant:(WMParticipant *)participant
                                                                                   create:(BOOL)create
                                                                     managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

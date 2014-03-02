#import "_WMWoundMeasurementInterventionEvent.h"
#import "WMInterventionEventType.h"

@interface WMWoundMeasurementInterventionEvent : _WMWoundMeasurementInterventionEvent {}

+ (WMWoundMeasurementInterventionEvent *)woundMeasurementInterventionEventForWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup
                                                                                        changeType:(InterventionEventChangeType)changeType
                                                                                             title:(NSString *)title
                                                                                         valueFrom:(id)valueFrom
                                                                                           valueTo:(id)valueTo
                                                                                              type:(WMInterventionEventType *)eventType
                                                                                       participant:(WMParticipant *)participant
                                                                                            create:(BOOL)create
                                                                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                                                   persistentStore:(NSPersistentStore *)store;

@end

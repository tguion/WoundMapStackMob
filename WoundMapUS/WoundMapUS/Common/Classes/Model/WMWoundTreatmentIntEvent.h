#import "_WMWoundTreatmentIntEvent.h"
#import "WMInterventionEventType.h"

@interface WMWoundTreatmentIntEvent : _WMWoundTreatmentIntEvent {}

+ (WMWoundTreatmentIntEvent *)woundTreatmentInterventionEventForWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
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

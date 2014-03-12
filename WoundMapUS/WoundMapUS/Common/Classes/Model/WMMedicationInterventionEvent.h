#import "_WMMedicationInterventionEvent.h"
#import "WMInterventionEventType.h"

@interface WMMedicationInterventionEvent : _WMMedicationInterventionEvent {}

+ (WMMedicationInterventionEvent *)medicationInterventionEventForMedicationGroup:(WMMedicationGroup *)medicationGroup
                                                                      changeType:(InterventionEventChangeType)changeType
                                                                           title:(NSString *)title
                                                                       valueFrom:(id)valueFrom
                                                                         valueTo:(id)valueTo
                                                                            type:(WMInterventionEventType *)eventType
                                                                     participant:(WMParticipant *)participant
                                                                          create:(BOOL)create
                                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

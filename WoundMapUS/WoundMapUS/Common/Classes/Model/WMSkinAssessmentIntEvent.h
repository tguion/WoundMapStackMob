#import "_WMSkinAssessmentIntEvent.h"
#import "WMInterventionEventType.h"

@interface WMSkinAssessmentIntEvent : _WMSkinAssessmentIntEvent {}

+ (WMSkinAssessmentIntEvent *)skinAssessmentInterventionEventForSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
                                                                         changeType:(InterventionEventChangeType)changeType
                                                                              title:(NSString *)title
                                                                          valueFrom:(id)valueFrom
                                                                            valueTo:(id)valueTo
                                                                               type:(WMInterventionEventType *)eventType
                                                                        participant:(WMParticipant *)participant
                                                                             create:(BOOL)create
                                                               managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

#import "_WMSkinAssessmentInterventionEvent.h"
#import "WMInterventionEventType.h"

@interface WMSkinAssessmentInterventionEvent : _WMSkinAssessmentInterventionEvent {}

+ (WMSkinAssessmentInterventionEvent *)skinAssessmentInterventionEventForSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
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

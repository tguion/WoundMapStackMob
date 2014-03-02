#import "_WMPsychoSocialInterventionEvent.h"
#import "WMInterventionEventType.h"

@interface WMPsychoSocialInterventionEvent : _WMPsychoSocialInterventionEvent {}

+ (WMPsychoSocialInterventionEvent *)psychoSocialInterventionEventForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
                                                                            changeType:(InterventionEventChangeType)changeType
                                                                                  path:(NSString *)path
                                                                                 title:(NSString *)title
                                                                             valueFrom:(id)valueFrom
                                                                               valueTo:(id)valueTo
                                                                                  type:(WMInterventionEventType *)eventType
                                                                           participant:(WMParticipant *)participant
                                                                                create:(BOOL)create
                                                                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                                       persistentStore:(NSPersistentStore *)store;

@end

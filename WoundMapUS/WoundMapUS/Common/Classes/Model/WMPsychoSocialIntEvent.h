#import "_WMPsychoSocialIntEvent.h"
#import "WMInterventionEventType.h"

@interface WMPsychoSocialIntEvent : _WMPsychoSocialIntEvent {}

+ (WMPsychoSocialIntEvent *)psychoSocialInterventionEventForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
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

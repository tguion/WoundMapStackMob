#import "_WMCarePlanInterventionEvent.h"
#import "WMInterventionEventType.h"

@class WMCarePlanGroup, WMParticipant, WMInterventionEventType;

@interface WMCarePlanInterventionEvent : _WMCarePlanInterventionEvent {}

+ (WMCarePlanInterventionEvent *)carePlanInterventionEventForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
                                                                changeType:(InterventionEventChangeType)changeType
                                                                      path:(NSString *)path
                                                                     title:(NSString *)title
                                                                 valueFrom:(id)valueFrom
                                                                   valueTo:(id)valueTo
                                                                      type:(WMInterventionEventType *)eventType
                                                               participant:(WMParticipant *)participant
                                                                    create:(BOOL)create
                                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

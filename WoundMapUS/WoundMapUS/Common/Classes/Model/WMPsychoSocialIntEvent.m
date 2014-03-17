#import "WMPsychoSocialIntEvent.h"
#import "WMPsychoSocialGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMPsychoSocialIntEvent ()

// Private interface goes here.

@end


@implementation WMPsychoSocialIntEvent

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
{
    NSParameterAssert([psychoSocialGroup managedObjectContext] == managedObjectContext);
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    if (nil != eventType) {
        NSParameterAssert([eventType managedObjectContext] == managedObjectContext);
    }
    WMPsychoSocialIntEvent *psychoSocialInterventionEvent = [WMPsychoSocialIntEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                                               @"group == %@ AND changeType == %d AND path == %@ AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                                               psychoSocialGroup, changeType, path, title, valueFrom, valueTo, eventType, participant] inContext:managedObjectContext];
    if (create && nil == psychoSocialInterventionEvent) {
        psychoSocialInterventionEvent = [WMPsychoSocialIntEvent MR_createInContext:managedObjectContext];
        psychoSocialInterventionEvent.group = psychoSocialGroup;
        psychoSocialInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        psychoSocialInterventionEvent.path = path;
        psychoSocialInterventionEvent.title = title;
        psychoSocialInterventionEvent.valueFrom = valueFrom;
        psychoSocialInterventionEvent.valueTo = valueTo;
        psychoSocialInterventionEvent.eventType = eventType;
        psychoSocialInterventionEvent.participant = participant;
    }
    return psychoSocialInterventionEvent;
}

@end

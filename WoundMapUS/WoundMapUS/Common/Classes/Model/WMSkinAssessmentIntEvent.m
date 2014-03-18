#import "WMSkinAssessmentIntEvent.h"
#import "WMSkinAssessmentGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"

@interface WMSkinAssessmentIntEvent ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentIntEvent

+ (WMSkinAssessmentIntEvent *)skinAssessmentInterventionEventForSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
                                                                                  changeType:(InterventionEventChangeType)changeType
                                                                                       title:(NSString *)title
                                                                                   valueFrom:(id)valueFrom
                                                                                     valueTo:(id)valueTo
                                                                                        type:(WMInterventionEventType *)eventType
                                                                                 participant:(WMParticipant *)participant
                                                                                      create:(BOOL)create
                                                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert([skinAssessmentGroup managedObjectContext] == managedObjectContext);
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    if (nil != eventType) {
        NSParameterAssert([eventType managedObjectContext] == managedObjectContext);
    }
    WMSkinAssessmentIntEvent *skinAssessmentInterventionEvent = [WMSkinAssessmentIntEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                                                     @"skinAssessmentGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                                                     skinAssessmentGroup, changeType, title, valueFrom, valueTo, eventType, participant] inContext:managedObjectContext];
    if (create && nil == skinAssessmentInterventionEvent) {
        skinAssessmentInterventionEvent = [WMSkinAssessmentIntEvent MR_createInContext:managedObjectContext];
        skinAssessmentInterventionEvent.skinAssessmentGroup = skinAssessmentGroup;
        skinAssessmentInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        skinAssessmentInterventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            skinAssessmentInterventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            skinAssessmentInterventionEvent.valueTo = valueTo;
        }
        skinAssessmentInterventionEvent.eventType = eventType;
        skinAssessmentInterventionEvent.participant = participant;
    }
    return skinAssessmentInterventionEvent;
}

@end

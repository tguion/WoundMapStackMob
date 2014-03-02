#import "WMSkinAssessmentInterventionEvent.h"
#import "WMSkinAssessmentGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMSkinAssessmentInterventionEvent ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentInterventionEvent

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMSkinAssessmentInterventionEvent *skinAssessmentInterventionEvent = [[WMSkinAssessmentInterventionEvent alloc] initWithEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentInterventionEvent" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:skinAssessmentInterventionEvent toPersistentStore:store];
	}
    [skinAssessmentInterventionEvent setValue:[skinAssessmentInterventionEvent assignObjectId] forKey:[skinAssessmentInterventionEvent primaryKeyField]];
	return skinAssessmentInterventionEvent;
}

+ (WMSkinAssessmentInterventionEvent *)skinAssessmentInterventionEventForSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
                                                                                  changeType:(InterventionEventChangeType)changeType
                                                                                       title:(NSString *)title
                                                                                   valueFrom:(id)valueFrom
                                                                                     valueTo:(id)valueTo
                                                                                        type:(WMInterventionEventType *)eventType
                                                                                 participant:(WMParticipant *)participant
                                                                                      create:(BOOL)create
                                                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                                             persistentStore:(NSPersistentStore *)store
{
    skinAssessmentGroup = (WMSkinAssessmentGroup *)[managedObjectContext objectWithID:[skinAssessmentGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentInterventionEvent" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:
                           @"skinAssessmentGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                           skinAssessmentGroup, changeType, title, valueFrom, valueTo, eventType, participant]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMSkinAssessmentInterventionEvent *skinAssessmentInterventionEvent = [array lastObject];
    if (create && nil == skinAssessmentInterventionEvent) {
        skinAssessmentInterventionEvent = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
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

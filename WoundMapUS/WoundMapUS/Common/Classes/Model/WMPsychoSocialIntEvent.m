#import "WMPsychoSocialIntEvent.h"
#import "WMPsychoSocialGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMPsychoSocialIntEvent ()

// Private interface goes here.

@end


@implementation WMPsychoSocialIntEvent

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMPsychoSocialIntEvent *psychoSocialInterventionEvent = [[WMPsychoSocialIntEvent alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPsychoSocialIntEvent" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:psychoSocialInterventionEvent toPersistentStore:store];
	}
    [psychoSocialInterventionEvent setValue:[psychoSocialInterventionEvent assignObjectId] forKey:[psychoSocialInterventionEvent primaryKeyField]];
	return psychoSocialInterventionEvent;
}

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
                                                              persistentStore:(NSPersistentStore *)store
{
    psychoSocialGroup = (WMPsychoSocialGroup *)[managedObjectContext objectWithID:[psychoSocialGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialIntEvent" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:
                           @"group == %@ AND changeType == %d AND path == %@ AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                           psychoSocialGroup, changeType, path, title, valueFrom, valueTo, eventType, participant]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMPsychoSocialIntEvent *psychoSocialInterventionEvent = [array lastObject];
    if (create && nil == psychoSocialInterventionEvent) {
        psychoSocialInterventionEvent = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
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

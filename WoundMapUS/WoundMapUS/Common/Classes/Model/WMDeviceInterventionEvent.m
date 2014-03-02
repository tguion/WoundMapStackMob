#import "WMDeviceInterventionEvent.h"
#import "WMDeviceGroup.h"
#import "WMParticipant.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMDeviceInterventionEvent ()

// Private interface goes here.

@end


@implementation WMDeviceInterventionEvent

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMDeviceInterventionEvent *deviceInterventionEvent = [[WMDeviceInterventionEvent alloc] initWithEntity:[NSEntityDescription entityForName:@"WMDeviceInterventionEvent" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:deviceInterventionEvent toPersistentStore:store];
	}
    [deviceInterventionEvent setValue:[deviceInterventionEvent assignObjectId] forKey:[deviceInterventionEvent primaryKeyField]];
	return deviceInterventionEvent;
}

+ (WMDeviceInterventionEvent *)deviceInterventionEventForDeviceGroup:(WMDeviceGroup *)deviceGroup
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
    deviceGroup = (WMDeviceGroup *)[managedObjectContext objectWithID:[deviceGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMDeviceInterventionEvent" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:
                           @"deviceGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                           deviceGroup, changeType, title, valueFrom, valueTo, eventType, participant]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMDeviceInterventionEvent *deviceInterventionEvent = [array lastObject];
    if (create && nil == deviceInterventionEvent) {
        deviceInterventionEvent = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        deviceInterventionEvent.deviceGroup = deviceGroup;
        deviceInterventionEvent.changeType = [NSNumber numberWithInt:changeType];
        deviceInterventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            deviceInterventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            deviceInterventionEvent.valueTo = valueTo;
        }
        deviceInterventionEvent.eventType = eventType;
        deviceInterventionEvent.participant = participant;
    }
    return deviceInterventionEvent;
}

@end

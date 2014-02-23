#import "WMDeviceValue.h"
#import "StackMob.h"

@interface WMDeviceValue ()

// Private interface goes here.

@end


@implementation WMDeviceValue

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMDeviceValue *deviceValue = [[WMDeviceValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMDeviceValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:deviceValue toPersistentStore:store];
	}
    [deviceValue setValue:[deviceValue assignObjectId] forKey:[deviceValue primaryKeyField]];
	return deviceValue;
}

@end

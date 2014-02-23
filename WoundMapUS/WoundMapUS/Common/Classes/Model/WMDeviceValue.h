#import "_WMDeviceValue.h"

@interface WMDeviceValue : _WMDeviceValue {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end

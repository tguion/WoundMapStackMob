#import "_WMPhoto.h"

@interface WMPhoto : _WMPhoto {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end

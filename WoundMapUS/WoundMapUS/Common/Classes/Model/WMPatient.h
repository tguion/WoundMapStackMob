#import "_WMPatient.h"

@interface WMPatient : _WMPatient {}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;
@end

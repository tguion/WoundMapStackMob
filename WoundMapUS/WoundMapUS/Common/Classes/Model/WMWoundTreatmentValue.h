#import "_WMWoundTreatmentValue.h"

@interface WMWoundTreatmentValue : _WMWoundTreatmentValue {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end

#import "_WMWoundMeasurementValue.h"

@interface WMWoundMeasurementValue : _WMWoundMeasurementValue {}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;
@end

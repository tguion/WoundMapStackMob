#import "_WMWoundMeasurementValue.h"

@interface WMWoundMeasurementValue : _WMWoundMeasurementValue {}

@property (readonly) NSString *displayValue;

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;
@end

#import "_WMAddress.h"

@interface WMAddress : _WMAddress {}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

@property (readonly, nonatomic) NSString *stringValue;

@end

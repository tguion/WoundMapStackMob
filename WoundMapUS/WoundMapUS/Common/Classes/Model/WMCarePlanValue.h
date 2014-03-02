#import "_WMCarePlanValue.h"

@interface WMCarePlanValue : _WMCarePlanValue {}

@property (readonly, nonatomic) NSArray *categoryPathToValue;
@property (readonly, nonatomic) NSString *pathToValue;

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end

#import "_WMPsychoSocialValue.h"

@interface WMPsychoSocialValue : _WMPsychoSocialValue {}

@property (readonly, nonatomic) NSString *pathToValue;
@property (readonly, nonatomic) NSString *displayValue;

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end

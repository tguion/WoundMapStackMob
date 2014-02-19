#import "_WMPerson.h"

@interface WMPerson : _WMPerson {}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

@property (readonly, nonatomic) NSString *lastNameFirstName;

@end

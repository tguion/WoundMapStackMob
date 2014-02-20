#import "_WMPerson.h"
#import "WoundCareProtocols.h"

@interface WMPerson : _WMPerson  <AddressSource> {}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

@property (readonly, nonatomic) NSString *lastNameFirstName;

@end

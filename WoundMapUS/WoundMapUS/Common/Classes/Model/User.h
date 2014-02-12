#import "_User.h"

@interface User : _User {}

+ (instancetype)instanceUsername:(NSString *)username
                        password:(NSString *)password
            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                 persistentStore:(NSPersistentStore *)store;

+ (User *)userForUsername:(NSString *)username
     managedObjectContext:(NSManagedObjectContext *)managedObjectContext
          persistentStore:(NSPersistentStore *)store;

@end

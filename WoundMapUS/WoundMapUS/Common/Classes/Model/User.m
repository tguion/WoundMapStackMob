#import "User.h"


@interface User ()

// Private interface goes here.

@end


@implementation User

+ (instancetype)instanceUsername:(NSString *)username
                        password:(NSString *)password
            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                 persistentStore:(NSPersistentStore *)store
{
    User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:user toPersistentStore:store];
	}
    user.username = username;
    [user setPassword:password];
	return user;
}

+ (User *)userForUsername:(NSString *)username
     managedObjectContext:(NSManagedObjectContext *)managedObjectContext
          persistentStore:(NSPersistentStore *)store
{
    if ([username length] == 0) {
        return nil;
    }
    // else
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"username == %@", username]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        NSLog(@"TODO: handle error");
        abort();
    }
    // else
    NSAssert1([array count] < 2, @"More than one User for username %@", username);
    return [array lastObject];
}

@end

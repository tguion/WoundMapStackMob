#import "WMPerson.h"
#import "StackMob.h"

@interface WMPerson ()

// Private interface goes here.

@end


@implementation WMPerson

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMPerson *person = [[WMPerson alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPerson" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:person toPersistentStore:store];
	}
    [person setValue:[person assignObjectId] forKey:[person primaryKeyField]];
	return person;
}

@end

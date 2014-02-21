#import "WMId.h"
#import "StackMob.h"

@interface WMId ()

// Private interface goes here.

@end


@implementation WMId

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMId *anId = [[WMId alloc] initWithEntity:[NSEntityDescription entityForName:@"WMId" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:anId toPersistentStore:store];
	}
    [anId setValue:[anId assignObjectId] forKey:[anId primaryKeyField]];
	return anId;
}

@end

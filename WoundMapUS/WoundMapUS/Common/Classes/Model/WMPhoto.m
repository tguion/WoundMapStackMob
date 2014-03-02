#import "WMPhoto.h"
#import "StackMob.h"

@interface WMPhoto ()

// Private interface goes here.

@end


@implementation WMPhoto

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMPhoto *photo = [[WMPhoto alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPhoto" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:photo toPersistentStore:store];
	}
    [photo setValue:[photo assignObjectId] forKey:[photo primaryKeyField]];
	return photo;
}

@end

#import "WMNavigationTrack.h"
#import "StackMob.h"

@interface WMNavigationTrack ()

// Private interface goes here.

@end


@implementation WMNavigationTrack

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMNavigationTrack *navigationTrack = [[WMNavigationTrack alloc] initWithEntity:[NSEntityDescription entityForName:@"WMNavigationTrack" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:navigationTrack toPersistentStore:store];
	}
    [navigationTrack setValue:[navigationTrack assignObjectId] forKey:[navigationTrack primaryKeyField]];
	return navigationTrack;
}

+ (NSInteger)navigationTrackCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationTrack" inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

@end

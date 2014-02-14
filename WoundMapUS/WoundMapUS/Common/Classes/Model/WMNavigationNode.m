#import "WMNavigationNode.h"
#import "StackMob.h"

@interface WMNavigationNode ()

// Private interface goes here.

@end


@implementation WMNavigationNode

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMNavigationNode *navigationNode = [[WMNavigationNode alloc] initWithEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:navigationNode toPersistentStore:store];
	}
    [navigationNode setValue:[navigationNode assignObjectId] forKey:[navigationNode primaryKeyField]];
	return navigationNode;
}

+ (NSInteger)navigationNodeCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

@end

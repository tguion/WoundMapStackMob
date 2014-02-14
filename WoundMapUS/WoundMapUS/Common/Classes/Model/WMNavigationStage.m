#import "WMNavigationStage.h"
#import "StackMob.h"

@interface WMNavigationStage ()

// Private interface goes here.

@end


@implementation WMNavigationStage

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMNavigationStage *navigationStage = [[WMNavigationStage alloc] initWithEntity:[NSEntityDescription entityForName:@"WMNavigationStage" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:navigationStage toPersistentStore:store];
	}
    [navigationStage setValue:[navigationStage assignObjectId] forKey:[navigationStage primaryKeyField]];
	return navigationStage;
}

+ (NSInteger)navigationStageCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationStage" inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

@end

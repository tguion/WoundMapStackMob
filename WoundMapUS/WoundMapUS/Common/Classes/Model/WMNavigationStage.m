#import "WMNavigationStage.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WMUtilities.h"

NSString *const kInitialWorkupStageTitle = @"Initial Workup";
NSString *const kFollowupStageTitle = @"Follow Up";
NSString *const kDischargeStageTitle = @"Discharge";

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

- (NSArray *)rootNavigationNodes
{
    NSArray *nodes = self.nodes.allObjects;
    nodes = [nodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parentNode = nil"]];
    return [nodes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
}

- (BOOL)isInitialStage
{
    return [kInitialWorkupStageTitle isEqualToString:self.title];
}

- (void)updateFromNavigationStage:(WMNavigationStage *)navigationStage
       targetManagedObjectContext:(NSManagedObjectContext *)targetManagedObjectContext
           targetPersistenceStore:(NSPersistentStore *)targetStore
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"WMNavigationStage" inManagedObjectContext:[self managedObjectContext]];
    NSDictionary *attributesByName = entityDescription.attributesByName;
    for (NSString *key in attributesByName) {
        id value = [navigationStage valueForKey:key];
        [self setValue:value forKey:key];
    }
    // update nodes
    __block NSArray *rootNavigationNodes = nil;
    [[navigationStage managedObjectContext] performBlockAndWait:^{
        rootNavigationNodes = navigationStage.rootNavigationNodes;
    }];
    for (WMNavigationNode *navigationNode in rootNavigationNodes) {
        __block NSString *title = nil;
        [[navigationStage managedObjectContext] performBlockAndWait:^{
            title = navigationNode.title;
        }];
        WMNavigationNode *navigationNode2 = [WMNavigationNode nodeForTitle:title
                                                                     stage:self
                                                                parentNode:nil
                                                                    create:YES
                                                      managedObjectContext:targetManagedObjectContext
                                                           persistentStore:targetStore];
        NSAssert(nil != navigationNode2, @"WMNavigationNode missing for %@", navigationNode.title);
        [navigationNode2 updateFromNavigationNode:navigationNode
                       targetManagedObjectContext:targetManagedObjectContext
                           targetPersistenceStore:targetStore];
    }
}

+ (WMNavigationStage *)updateStageFromDictionary:(NSDictionary *)dictionary
                                           track:(WMNavigationTrack *)navigationTrack
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMNavigationStage *navigationStage = [WMNavigationStage stageForTitle:title
                                                                    track:navigationTrack
                                                                   create:create
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
    if (nil == navigationStage) {
        return nil;
    }
    // else
    navigationStage.disabledFlag = [dictionary objectForKey:@"disabledFlag"];
    navigationStage.displayTitle = [dictionary objectForKey:@"displayTitle"];
    navigationStage.icon = [dictionary objectForKey:@"icon"];
    navigationStage.sortRank = [dictionary objectForKey:@"sortRank"];
    navigationStage.desc = [dictionary objectForKey:@"desc"];
    // save stage before attempting to form relationship with node
    NSError *error = nil;
    [managedObjectContext saveAndWait:&error];
    [WMUtilities logError:error];
    id nodes = [dictionary objectForKey:@"nodes"];
    if ([nodes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in nodes) {
            [WMNavigationNode updateNodeFromDictionary:d
                                                 stage:navigationStage
                                            parentNode:nil
                                                create:create
                                  managedObjectContext:managedObjectContext
                                       persistentStore:store];
        }
    }
    return navigationStage;
}

+ (NSArray *)sortedStagesForTrack:(WMNavigationTrack *)navigationTrack
{
    NSManagedObjectContext *managedObjectContext = [navigationTrack managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationStage" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"track == %@", navigationTrack]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

+ (WMNavigationStage *)initialStageForTrack:(WMNavigationTrack *)navigationTrack
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            persistentStore:(NSPersistentStore *)store
{
    return [self stageForTitle:kInitialWorkupStageTitle track:navigationTrack create:NO managedObjectContext:managedObjectContext persistentStore:store];
}

+ (WMNavigationStage *)followupStageForTrack:(WMNavigationTrack *)navigationTrack
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store
{
    return [self stageForTitle:kFollowupStageTitle track:navigationTrack create:NO managedObjectContext:managedObjectContext persistentStore:store];
}

+ (WMNavigationStage *)dischargeStageForTrack:(WMNavigationTrack *)navigationTrack
                         managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                              persistentStore:(NSPersistentStore *)store
{
    return [self stageForTitle:kDischargeStageTitle track:navigationTrack create:NO managedObjectContext:managedObjectContext persistentStore:store];
}

+ (WMNavigationStage *)stageForTitle:(NSString *)title
                               track:(WMNavigationTrack *)navigationTrack
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                     persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationStage" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND track == %@", title, navigationTrack]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMNavigationStage *navigationStage = [array lastObject];
    if (create && nil == navigationStage) {
        navigationStage = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationStage.title = title;
        navigationStage.track = navigationTrack;
    }
    return navigationStage;
}

@end

#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    NavigationTrackFlagsIgnoreStages                = 0,
    NavigationTrackFlagsIgnoreSignin                = 1,
    NavigationTrackFlagsLimitToSinglePatient        = 2,
    NavigationTrackFlagsSkipCarePlan                = 3,
    NavigationTrackFlagsSkipPolicyEditor            = 4,
} NavigationTrackFlags;

@interface WMNavigationTrack ()

// Private interface goes here.

@end


@implementation WMNavigationTrack

- (BOOL)ignoresStagesFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreStages];
}

- (void)setIgnoresStagesFlag:(BOOL)ignoresStagesFlag
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreStages to:ignoresStagesFlag]];
}

- (BOOL)ignoresSignInFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreSignin];
}

- (void)setIgnoresSignInFlag:(BOOL)ignoresSignInFlag
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreSignin to:ignoresSignInFlag]];
}

- (BOOL)limitToSinglePatientFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsLimitToSinglePatient];
}

- (void)setLimitToSinglePatientFlag:(BOOL)limitToSinglePatientFlag
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsLimitToSinglePatient to:limitToSinglePatientFlag]];
}

- (BOOL)skipCarePlanFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipCarePlan];
}

- (void)setSkipCarePlanFlag:(BOOL)skipCarePlanFlag
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipCarePlan to:skipCarePlanFlag]];
}

- (BOOL)skipPolicyEditor
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipPolicyEditor];
}

- (void)setSkipPolicyEditor:(BOOL)skipPolicyEditor
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipPolicyEditor to:skipPolicyEditor]];
}

- (WMNavigationStage *)initialStage
{
    NSArray *stages = [[self.stages allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:NO]]];
    return [stages lastObject];
}

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

// first attempt to find WMNavigationTrack data in index store
+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"NavigationTracks" withExtension:@"plist"];
    if (nil == fileURL) {
        DLog(@"NavigationTracks.plist file not found");
        return;
    }
    // else check if already loaded
    if ([WMNavigationTrack navigationTrackCount:managedObjectContext persistentStore:store] > 0) {
        return;
    }
    // else
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an NSArray, class was %@", NSStringFromClass([propertyList class]));
        [managedObjectContext performBlockAndWait:^{
            for (NSDictionary *dictionary in propertyList) {
                [self updateTrackFromDictionary:dictionary create:YES managedObjectContext:managedObjectContext persistentStore:store];
            }
            // create patient and wound nodes
            [WMNavigationNode seedPatientNodes:managedObjectContext persistentStore:store];
            [WMNavigationNode seedWoundNodes:managedObjectContext persistentStore:store];
        }];
    }
}

+ (void)seedDatabaseSourceManagedObjectContext:(NSManagedObjectContext *)sourceManagedObjectContext
                         sourcePersistentStore:(NSPersistentStore *)sourceStore
                    targetManagedObjectContext:(NSManagedObjectContext *)targetManagedObjectContext
                        targetPersistenceStore:(NSPersistentStore *)targetStore
{
    __block NSArray *navigationTracks = nil;
    [sourceManagedObjectContext performBlockAndWait:^{
        navigationTracks = [WMNavigationTrack sortedTracks:sourceManagedObjectContext persistentStore:sourceStore];
    }];
    for (WMNavigationTrack *navigationTrack in navigationTracks) {
        __block NSString *title = nil;
        [sourceManagedObjectContext performBlockAndWait:^{
            title = navigationTrack.title;
        }];
        WMNavigationTrack *navigationTrack2 = [self trackForTitle:title
                                                           create:YES
                                             managedObjectContext:targetManagedObjectContext
                                                  persistentStore:targetStore];
        NSAssert(nil != navigationTrack2, @"WCNavigtionTrack missing for %@", navigationTrack.title);
        [navigationTrack2 updateFromNavigationTrack:navigationTrack
                         targetManagedObjectContext:targetManagedObjectContext
                             targetPersistenceStore:targetStore];
    }
    
}

// - (NSDictionary *)relationshipsByName
- (void)updateFromNavigationTrack:(WMNavigationTrack *)navigationTrack
       targetManagedObjectContext:(NSManagedObjectContext *)targetManagedObjectContext
           targetPersistenceStore:(NSPersistentStore *)targetStore
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"WMNavigationTrack" inManagedObjectContext:[self managedObjectContext]];
    NSDictionary *attributesByName = entityDescription.attributesByName;
    for (NSString *key in attributesByName) {
        id value = [navigationTrack valueForKey:key];
        [self setValue:value forKey:key];
    }
    // update stages
    __block NSSet *stages = nil;
    [[navigationTrack managedObjectContext] performBlockAndWait:^{
        stages = navigationTrack.stages;
    }];
    for (WMNavigationStage *navigationStage in stages) {
        __block NSString *title = nil;
        [[navigationTrack managedObjectContext] performBlockAndWait:^{
            title = navigationStage.title;
        }];
        WMNavigationStage *navigationStage2 = [WMNavigationStage stageForTitle:title
                                                                         track:self
                                                                        create:YES
                                                          managedObjectContext:targetManagedObjectContext
                                                               persistentStore:targetStore];
        NSAssert(nil != navigationStage2, @"WMNavigationStage missing for %@", navigationStage.title);
        [navigationStage2 updateFromNavigationStage:navigationStage
                         targetManagedObjectContext:targetManagedObjectContext
                             targetPersistenceStore:targetStore];
    }
}

+ (WMNavigationTrack *)updateTrackFromDictionary:(NSDictionary *)dictionary
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMNavigationTrack *navigationTrack = [WMNavigationTrack trackForTitle:title
                                                                   create:create
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
    navigationTrack.displayTitle = [dictionary objectForKey:@"displayTitle"];
    navigationTrack.icon = [dictionary objectForKey:@"icon"];
    navigationTrack.sortRank = [dictionary objectForKey:@"sortRank"];
    navigationTrack.disabledFlag = [dictionary objectForKey:@"disabledFlag"];
    navigationTrack.desc = [dictionary objectForKey:@"desc"];
    navigationTrack.ignoresStagesFlag = [[dictionary objectForKey:@"ignoresStagesFlag"] boolValue];
    navigationTrack.ignoresSignInFlag = [[dictionary objectForKey:@"ignoresSignInFlag"] boolValue];
    navigationTrack.limitToSinglePatientFlag = [[dictionary objectForKey:@"limitToSinglePatientFlag"] boolValue];
    navigationTrack.skipCarePlanFlag = [[dictionary objectForKey:@"skipCarePlanFlag"] boolValue];
    navigationTrack.skipPolicyEditor = [[dictionary objectForKey:@"skipPolicyEditor"] boolValue];
    // save track before attempting to form relationship with stage
    NSError *error = nil;
    [managedObjectContext saveAndWait:&error];
    [WMUtilities logError:error];
    id stages = [dictionary objectForKey:@"stages"];
    if ([stages isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in stages) {
            [WMNavigationStage updateStageFromDictionary:d
                                                   track:navigationTrack
                                                  create:create
                                    managedObjectContext:managedObjectContext
                                         persistentStore:store];
        }
    }
    return navigationTrack;
}

+ (NSArray *)sortedTracks:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WCNavigationTrack" inManagedObjectContext:managedObjectContext]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return array;
}

+ (WMNavigationTrack *)trackForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                     persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationTrack" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationTrack *navigationTrack = [array lastObject];
    if (create && nil == navigationTrack) {
        navigationTrack = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationTrack.title = title;
    }
    return navigationTrack;
}

@end

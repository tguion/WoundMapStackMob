#import "WMNavigationStage.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import <FFEF/FatFractal.h>

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
	return navigationStage;
}

+ (NSInteger)navigationStageCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMNavigationStage countOfEntitiesWithContext:managedObjectContext];
}

- (NSArray *)rootNavigationNodes
{
    return [WMNavigationStage MR_findAllSortedBy:@"sortRank"
                                       ascending:YES
                                   withPredicate:[NSPredicate predicateWithFormat:@"parentNode = nil"]
                                       inContext:[self managedObjectContext]];
}

- (BOOL)isInitialStage
{
    return [kInitialWorkupStageTitle isEqualToString:self.title];
}

+ (WMNavigationStage *)updateStageFromDictionary:(NSDictionary *)dictionary
                                           track:(WMNavigationTrack *)navigationTrack
                                          create:(BOOL)create
{
    id title = [dictionary objectForKey:@"title"];
    WMNavigationStage *navigationStage = [WMNavigationStage stageForTitle:title
                                                                    track:navigationTrack
                                                                   create:create];
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
    NSManagedObjectContext *managedObjectContext = [navigationTrack managedObjectContext];
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            // save to back end
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            [ff queueCreateObj:navigationStage atUri:@"/WMNavigationStage"];
            id nodes = [dictionary objectForKey:@"nodes"];
            if ([nodes isKindOfClass:[NSArray class]]) {
                for (NSDictionary *d in nodes) {
                    [WMNavigationNode updateNodeFromDictionary:d
                                                         stage:navigationStage
                                                    parentNode:nil
                                                        create:create];
                }
            }
        }
    }];
    return navigationStage;
}

+ (NSArray *)sortedStagesForTrack:(WMNavigationTrack *)navigationTrack
{
    return [WMNavigationStage MR_findAllSortedBy:@"sortRank"
                                       ascending:YES
                                   withPredicate:[NSPredicate predicateWithFormat:@"track == %@", navigationTrack]
                                       inContext:[navigationTrack managedObjectContext]];
}

+ (WMNavigationStage *)initialStageForTrack:(WMNavigationTrack *)navigationTrack
{
    return [self stageForTitle:kInitialWorkupStageTitle track:navigationTrack create:NO];
}

+ (WMNavigationStage *)followupStageForTrack:(WMNavigationTrack *)navigationTrack
{
    return [self stageForTitle:kFollowupStageTitle track:navigationTrack create:NO];
}

+ (WMNavigationStage *)dischargeStageForTrack:(WMNavigationTrack *)navigationTrack
{
    return [self stageForTitle:kDischargeStageTitle track:navigationTrack create:NO];
}

+ (WMNavigationStage *)stageForTitle:(NSString *)title
                               track:(WMNavigationTrack *)navigationTrack
                              create:(BOOL)create
{
    NSManagedObjectContext *managedObjectContext = [navigationTrack managedObjectContext];
    WMNavigationStage *navigationStage = [WMNavigationStage MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND track == %@", title, navigationTrack]
                                                                            inContext:managedObjectContext];
    if (create && nil == navigationStage) {
        navigationStage = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        navigationStage.title = title;
        navigationStage.track = navigationTrack;
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [ff queueCreateObj:navigationTrack atUri:@"/WMNavigationStage"];
    }
    return navigationStage;
}

@end

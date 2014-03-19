#import "WMNavigationStage.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

NSString *const kInitialWorkupStageTitle = @"Initial Workup";
NSString *const kFollowupStageTitle = @"Follow Up";
NSString *const kDischargeStageTitle = @"Discharge";

@interface WMNavigationStage ()

// Private interface goes here.

@end


@implementation WMNavigationStage

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
                               completionHandler:(WMProcessCallback)completionHandler
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
    id nodes = [dictionary objectForKey:@"nodes"];
    if ([nodes isKindOfClass:[NSArray class]]) {
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *d in nodes) {
            WMNavigationNode *navigationNode = [WMNavigationNode updateNodeFromDictionary:d
                                                                                    stage:navigationStage
                                                                               parentNode:nil
                                                                                   create:create
                                                                        completionHandler:completionHandler];
            NSAssert(![[navigationNode objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[navigationNode objectID]];
        }
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMNavigationNode entityName]);
        }
    }
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
        navigationStage = [WMNavigationStage MR_createInContext:managedObjectContext];
        navigationStage.title = title;
        navigationStage.track = navigationTrack;
    }
    return navigationStage;
}

@end

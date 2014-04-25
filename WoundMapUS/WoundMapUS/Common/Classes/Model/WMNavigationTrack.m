#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMTeam.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"
#import "WMFatFractal.h"
#import "NSObject+performBlockAfterDelay.h"

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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)ignoresStagesFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreStages];
}

- (void)setIgnoresStagesFlag:(BOOL)ignoresStagesFlag
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreStages to:ignoresStagesFlag]);
}

- (BOOL)ignoresSignInFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreSignin];
}

- (void)setIgnoresSignInFlag:(BOOL)ignoresSignInFlag
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsIgnoreSignin to:ignoresSignInFlag]);
}

- (BOOL)limitToSinglePatientFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsLimitToSinglePatient];
}

- (void)setLimitToSinglePatientFlag:(BOOL)limitToSinglePatientFlag
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsLimitToSinglePatient to:limitToSinglePatientFlag]);
}

- (BOOL)skipCarePlanFlag
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipCarePlan];
}

- (void)setSkipCarePlanFlag:(BOOL)skipCarePlanFlag
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipCarePlan to:skipCarePlanFlag]);
}

- (BOOL)skipPolicyEditor
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipPolicyEditor];
}

- (void)setSkipPolicyEditor:(BOOL)skipPolicyEditor
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationTrackFlagsSkipPolicyEditor to:skipPolicyEditor]);
}

- (WMNavigationStage *)initialStage
{
    NSArray *stages = [[self.stages allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:NO]]];
    return [stages lastObject];
}

+ (NSInteger)navigationTrackCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMNavigationTrack MR_countOfEntitiesWithContext:managedObjectContext];
}

// first attempt to find WMNavigationTrack data in index store
+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"NavigationTracks" withExtension:@"plist"];
    if (nil == fileURL) {
        DLog(@"NavigationTracks.plist file not found");
        return;
    }
    // else check if already loaded
    if ([WMNavigationTrack navigationTrackCount:managedObjectContext] > 0) {
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
        for (NSDictionary *dictionary in propertyList) {
            [self updateTrackFromDictionary:dictionary team:nil create:YES managedObjectContext:managedObjectContext];
        }
        // create patient and wound nodes
        [WMNavigationNode seedPatientNodes:managedObjectContext];
        [WMNavigationNode seedWoundNodes:managedObjectContext];
        if (!completionHandler) {
            return;
        }
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        // else now gather the objectIDs
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        NSArray *navigationTracks = [WMNavigationTrack MR_findAllInContext:managedObjectContext];
        NSArray *navigationTrackObjectIDs = [navigationTracks valueForKeyPath:@"objectID"];
        // remove the stages
        NSMutableDictionary *trackObjectID2Stages = [NSMutableDictionary dictionaryWithCapacity:[navigationTrackObjectIDs count]];
        for (WMNavigationTrack *navigationTrack in navigationTracks) {
            trackObjectID2Stages[[navigationTrack objectID]] = navigationTrack.stages;
            navigationTrack.stages = nil;
        }
        dispatch_block_t block0 = ^{
            for (WMNavigationTrack *navigationTrack in navigationTracks) {
                navigationTrack.stages = trackObjectID2Stages[[navigationTrack objectID]];
            }
            // now stages
            NSArray *stages = [WMNavigationStage MR_findAllInContext:managedObjectContext];
            NSArray *stageobjectIDs = [stages valueForKeyPath:@"objectID"];
            NSMutableDictionary *stageObjectID2Nodes = [NSMutableDictionary dictionaryWithCapacity:[stageobjectIDs count]];
            for (WMNavigationStage *navigationStage in stages) {
                stageObjectID2Nodes[[navigationStage objectID]] = navigationStage.nodes;
                navigationStage.nodes = nil;
            }
            completionHandler(nil, stageobjectIDs, [WMNavigationStage entityName], ^{
                NSError *error = nil;
                for (WMNavigationStage *navigationStage in stages) {
                    [ff grabBagAdd:navigationStage to:navigationStage.track grabBagName:WMNavigationTrackRelationships.stages error:&error];
                    navigationStage.nodes = stageObjectID2Nodes[[navigationStage objectID]];
                }
                __block NSArray *nodes = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode = nil"] inContext:managedObjectContext];
                NSArray *nodeObjectIDs = [nodes  valueForKeyPath:@"objectID"];
                NSMutableDictionary *nodeObjectID2Nodes = [NSMutableDictionary dictionaryWithCapacity:[nodeObjectIDs count]];
                for (WMNavigationNode *navigationNode in nodes) {
                    nodeObjectID2Nodes[[navigationNode objectID]] = navigationNode.subnodes;
                    navigationNode.subnodes = nil;
                }
                completionHandler(nil, nodeObjectIDs, [WMNavigationNode entityName], ^{
                    for (WMNavigationNode *navigationNode in nodes) {
                        NSError *error = nil;
                        if (navigationNode.stage) {
                            [ff grabBagAdd:navigationNode to:navigationNode.stage grabBagName:WMNavigationStageRelationships.nodes error:&error];
                        }
                        navigationNode.subnodes = nodeObjectID2Nodes[[navigationNode objectID]];
                    }
                    while (YES) {
                        NSArray *subnodes = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode IN (%@)", nodes] inContext:managedObjectContext];
                        if ([subnodes count] == 0) {
                            break;
                        }
                        // else
                        NSArray *subnodeObjectIDs = [subnodes valueForKeyPath:@"objectID"];
                        NSMutableDictionary *nodeObjectID2Nodes = [NSMutableDictionary dictionaryWithCapacity:[subnodeObjectIDs count]];
                        for (WMNavigationNode *navigationNode in subnodes) {
                            nodeObjectID2Nodes[[navigationNode objectID]] = navigationNode.subnodes;
                            navigationNode.subnodes = nil;
                        }
                        completionHandler(nil, subnodeObjectIDs, [WMNavigationNode entityName], ^{
                            NSError *error = nil;
                            for (WMNavigationNode *navigationNode in subnodes) {
                                if (navigationNode.stage) {
                                    [ff grabBagAdd:navigationNode to:navigationNode.stage grabBagName:WMNavigationStageRelationships.nodes error:&error];
                                }
                                if (navigationNode.parentNode) {
                                    [ff grabBagAdd:navigationNode to:navigationNode.parentNode grabBagName:WMNavigationNodeRelationships.subnodes error:&error];
                                }
                                navigationNode.subnodes = nodeObjectID2Nodes[[navigationNode objectID]];
                            }
                            nodes = subnodes;
                        });
                    }
                    
                });
            });
        };
        completionHandler(nil, navigationTrackObjectIDs, [WMNavigationTrack entityName], block0);
    }
}

+ (void)seedDatabaseForTeam:(WMTeam *)team completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"NavigationTracks" withExtension:@"plist"];
    if (nil == fileURL) {
        DLog(@"NavigationTracks.plist file not found");
        return;
    }
    // else check if already loaded
    NSManagedObjectContext *managedObjectContext = [team managedObjectContext];
    if ([[WMNavigationTrack MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"team == %@", team] inContext:managedObjectContext] count] > 0) {
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
        for (NSDictionary *dictionary in propertyList) {
            [self updateTrackFromDictionary:dictionary team:team create:YES managedObjectContext:managedObjectContext];
        }
        if (!completionHandler) {
            return;
        }
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        // else now gather the objectIDs
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        NSArray *navigationTracks = [WMNavigationTrack MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"team == %@", team] inContext:managedObjectContext];
        NSArray *navigationTrackObjectIDs = [navigationTracks valueForKeyPath:@"objectID"];
        // remove the stages
        NSMutableDictionary *trackObjectID2Stages = [NSMutableDictionary dictionaryWithCapacity:[navigationTrackObjectIDs count]];
        for (WMNavigationTrack *navigationTrack in navigationTracks) {
            trackObjectID2Stages[[navigationTrack objectID]] = navigationTrack.stages;
            navigationTrack.stages = nil;
        }
        dispatch_block_t block0 = ^{
            for (WMNavigationTrack *navigationTrack in navigationTracks) {
                navigationTrack.stages = trackObjectID2Stages[[navigationTrack objectID]];
            }
            // now stages
            NSArray *stages = [WMNavigationStage MR_findAllInContext:managedObjectContext];
            NSArray *stageobjectIDs = [stages valueForKeyPath:@"objectID"];
            NSMutableDictionary *stageObjectID2Nodes = [NSMutableDictionary dictionaryWithCapacity:[stageobjectIDs count]];
            for (WMNavigationStage *navigationStage in stages) {
                stageObjectID2Nodes[[navigationStage objectID]] = navigationStage.nodes;
                navigationStage.nodes = nil;
            }
            completionHandler(nil, stageobjectIDs, [WMNavigationStage entityName], ^{
                NSError *error = nil;
                for (WMNavigationStage *navigationStage in stages) {
                    [ff grabBagAdd:navigationStage to:navigationStage.track grabBagName:WMNavigationTrackRelationships.stages error:&error];
                    navigationStage.nodes = stageObjectID2Nodes[[navigationStage objectID]];
                }
                __block NSArray *nodes = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode = nil"] inContext:managedObjectContext];
                NSArray *nodeObjectIDs = [nodes  valueForKeyPath:@"objectID"];
                NSMutableDictionary *nodeObjectID2Nodes = [NSMutableDictionary dictionaryWithCapacity:[nodeObjectIDs count]];
                for (WMNavigationNode *navigationNode in nodes) {
                    nodeObjectID2Nodes[[navigationNode objectID]] = navigationNode.subnodes;
                    navigationNode.subnodes = nil;
                }
                completionHandler(nil, nodeObjectIDs, [WMNavigationNode entityName], ^{
                    for (WMNavigationNode *navigationNode in nodes) {
                        NSError *error = nil;
                        if (navigationNode.stage) {
                            [ff grabBagAdd:navigationNode to:navigationNode.stage grabBagName:WMNavigationStageRelationships.nodes error:&error];
                        }
                        navigationNode.subnodes = nodeObjectID2Nodes[[navigationNode objectID]];
                    }
                    while (YES) {
                        NSArray *subnodes = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode IN (%@)", nodes] inContext:managedObjectContext];
                        if ([subnodes count] == 0) {
                            break;
                        }
                        // else
                        NSArray *subnodeObjectIDs = [subnodes valueForKeyPath:@"objectID"];
                        NSMutableDictionary *nodeObjectID2Nodes = [NSMutableDictionary dictionaryWithCapacity:[subnodeObjectIDs count]];
                        for (WMNavigationNode *navigationNode in subnodes) {
                            nodeObjectID2Nodes[[navigationNode objectID]] = navigationNode.subnodes;
                            navigationNode.subnodes = nil;
                        }
                        completionHandler(nil, subnodeObjectIDs, [WMNavigationNode entityName], ^{
                            NSError *error = nil;
                            for (WMNavigationNode *navigationNode in subnodes) {
                                if (navigationNode.stage) {
                                    [ff grabBagAdd:navigationNode to:navigationNode.stage grabBagName:WMNavigationStageRelationships.nodes error:&error];
                                }
                                if (navigationNode.parentNode) {
                                    [ff grabBagAdd:navigationNode to:navigationNode.parentNode grabBagName:WMNavigationNodeRelationships.subnodes error:&error];
                                }
                                navigationNode.subnodes = nodeObjectID2Nodes[[navigationNode objectID]];
                            }
                            nodes = subnodes;
                        });
                    }
                    
                });
            });
        };
        completionHandler(nil, navigationTrackObjectIDs, [WMNavigationTrack entityName], block0);
    }
}

+ (WMNavigationTrack *)updateTrackFromDictionary:(NSDictionary *)dictionary
                                            team:(WMTeam *)team
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMNavigationTrack *navigationTrack = [WMNavigationTrack trackForTitle:title
                                                                     team:team
                                                                   create:create
                                                     managedObjectContext:managedObjectContext];
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
    [managedObjectContext MR_saveOnlySelfAndWait];
    id stages = [dictionary objectForKey:@"stages"];
    if ([stages isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in stages) {
            [WMNavigationStage updateStageFromDictionary:d
                                                   track:navigationTrack
                                                  create:create];
        }
    }
    return navigationTrack;
}

+ (NSArray *)sortedTracks:(NSManagedObjectContext *)managedObjectContext
{
    return [WMNavigationTrack MR_findAllSortedBy:WMNavigationNodeAttributes.sortRank ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"team == nil"] inContext:managedObjectContext];
}

+ (NSArray *)sortedTracksForTeam:(WMTeam *)team
{
    return [WMNavigationTrack MR_findAllSortedBy:WMNavigationNodeAttributes.sortRank ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"team == %@", team] inContext:[team managedObjectContext]];
}

+ (WMNavigationTrack *)trackForTitle:(NSString *)title
                                team:(WMTeam *)team
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMNavigationTrack *navigationTrack = [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND team == %@", title, team] inContext:managedObjectContext];
    if (create && nil == navigationTrack) {
        navigationTrack = [WMNavigationTrack MR_createInContext:managedObjectContext];
        navigationTrack.title = title;
        navigationTrack.team = team;
    }
    return navigationTrack;
}

+ (WMNavigationTrack *)trackForFFURL:(NSString *)ffUrl
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"ffUrl == %@", ffUrl] inContext:managedObjectContext];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"activeFlagValue",
                                                            @"disabledFlagValue",
                                                            @"flagsValue",
                                                            @"sortRankValue",
                                                            @"ignoresStagesFlag",
                                                            @"ignoresSignInFlag",
                                                            @"limitToSinglePatientFlag",
                                                            @"skipCarePlanFlag",
                                                            @"skipPolicyEditor",
                                                            @"initialStage"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMNavigationTrack attributeNamesNotToSerialize] containsObject:propertyName] || [[WMNavigationTrack relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMNavigationTrack relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

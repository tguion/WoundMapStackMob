#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMTeam.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"
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
        // else now gather the objectIDs
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        NSArray *objects = [WMNavigationTrack MR_findAllInContext:managedObjectContext];
        NSArray *objectIDs = [objects valueForKeyPath:@"objectID"];
        completionHandler(nil, objectIDs, [WMNavigationTrack entityName], nil);
        objects = [WMNavigationStage MR_findAllInContext:managedObjectContext];
        objectIDs = [objects valueForKeyPath:@"objectID"];
        completionHandler(nil, objectIDs, [WMNavigationStage entityName], nil);
        objects = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode = nil"] inContext:managedObjectContext];
        objectIDs = [objects valueForKeyPath:@"objectID"];
        completionHandler(nil, objectIDs, [WMNavigationNode entityName], nil);
        while (YES) {
            objects = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode IN (%@)", objects] inContext:managedObjectContext];
            if ([objects count] == 0) {
                break;
            }
            // else
            objectIDs = [objects valueForKeyPath:@"objectID"];
            completionHandler(nil, objectIDs, [WMNavigationNode entityName], nil);
        }
    }
}

+ (void)seedDatabaseForTeam:(WMTeam *)team completionHandler:(WMProcessCallback)completionHandler
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
        // else now gather the objectIDs
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        NSArray *objects = [WMNavigationTrack MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"team == %@", team] inContext:managedObjectContext];
        NSArray *objectIDs = [objects valueForKeyPath:@"objectID"];
        completionHandler(nil, objectIDs, [WMNavigationTrack entityName]);
        objects = [WMNavigationStage MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"track IN (%@)", objects] inContext:managedObjectContext];
        objectIDs = [objects valueForKeyPath:@"objectID"];
        completionHandler(nil, objectIDs, [WMNavigationStage entityName]);
        objects = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode = nil AND stage IN (%@)", objects] inContext:managedObjectContext];
        objectIDs = [objects valueForKeyPath:@"objectID"];
        completionHandler(nil, objectIDs, [WMNavigationNode entityName]);
        while (YES) {
            objects = [WMNavigationNode MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentNode IN (%@)", objects] inContext:managedObjectContext];
            if ([objects count] == 0) {
                break;
            }
            // else
            objectIDs = [objects valueForKeyPath:@"objectID"];
            completionHandler(nil, objectIDs, [WMNavigationNode entityName]);
        }
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMNavigationTrackRelationships.stages]];
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

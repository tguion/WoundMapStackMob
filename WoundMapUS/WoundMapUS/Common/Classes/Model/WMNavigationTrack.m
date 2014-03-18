#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"
#import <FFEF/FatFractal.h>
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
+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
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
        [managedObjectContext performBlockAndWait:^{
            for (NSDictionary *dictionary in propertyList) {
                [self updateTrackFromDictionary:dictionary create:YES managedObjectContext:managedObjectContext];
            }
            // create patient and wound nodes
            [WMNavigationNode seedPatientNodes:managedObjectContext];
            [WMNavigationNode seedWoundNodes:managedObjectContext];
        }];
    }
}

+ (WMNavigationTrack *)updateTrackFromDictionary:(NSDictionary *)dictionary
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMNavigationTrack *navigationTrack = [WMNavigationTrack trackForTitle:title
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
    // save track before attempting to form relationship with stage
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            id stages = [dictionary objectForKey:@"stages"];
            if ([stages isKindOfClass:[NSArray class]]) {
                for (NSDictionary *d in stages) {
                    [WMNavigationStage updateStageFromDictionary:d
                                                           track:navigationTrack
                                                          create:create];
                }
            }
        }
    }];
    return navigationTrack;
}

+ (NSArray *)sortedTracks:(NSManagedObjectContext *)managedObjectContext
{
    return [WMNavigationTrack MR_findAllSortedBy:@"sortRank" ascending:YES];
}

+ (WMNavigationTrack *)trackForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMNavigationTrack *navigationTrack = [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == navigationTrack) {
        navigationTrack = [WMNavigationTrack MR_createInContext:managedObjectContext];
        navigationTrack.title = title;
    }
    return navigationTrack;
}

+ (WMNavigationTrack *)trackForFFURL:(NSString *)ffUrl
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"ffUrl == %@", ffUrl] inContext:managedObjectContext];
}

@end

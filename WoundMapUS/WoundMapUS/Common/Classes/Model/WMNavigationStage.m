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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (NSInteger)navigationStageCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMNavigationStage countOfEntitiesWithContext:managedObjectContext];
}

- (NSArray *)rootNavigationNodes
{
    return [WMNavigationNode MR_findAllSortedBy:@"sortRank"
                                       ascending:YES
                                   withPredicate:[NSPredicate predicateWithFormat:@"stage == %@ AND parentNode = nil", self]
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
    id nodes = [dictionary objectForKey:@"nodes"];
    if ([nodes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in nodes) {
            [WMNavigationNode updateNodeFromDictionary:d
                                                 stage:navigationStage
                                            parentNode:nil
                                                create:create];
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

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return nil;
}

- (BOOL)requireUpdatesFromCloud
{
    return NO;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"disabledFlagValue",
                                                            @"flagsValue",
                                                            @"sortRankValue",
                                                            @"rootNavigationNodes",
                                                            @"isInitialStage",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMNavigationStageRelationships.patients, WMNavigationStageRelationships.nodes]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMNavigationStage attributeNamesNotToSerialize] containsObject:propertyName] || [[WMNavigationStage relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMNavigationStage relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

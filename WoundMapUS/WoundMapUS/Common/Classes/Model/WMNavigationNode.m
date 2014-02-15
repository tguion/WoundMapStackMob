#import "WMNavigationNode.h"
#import "WMNavigationStage.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    NavigationNodeFlagsRequired     = 0,
    NavigationNodeHidesStatus       = 1,
} NavigationNodeFlags;

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

- (NavigationNodeIdentifier)navigationNodeIdentifier
{
    return [self.taskIdentifier intValue];
}

- (NavigationNodeFrequencyUnit)frequencyUnitValue
{
    return [self.frequencyUnit integerValue];
}

- (void)setFrequencyUnitValue:(NavigationNodeFrequencyUnit)frequencyUnitValue
{
    self.frequencyUnit = [NSNumber numberWithInt:frequencyUnitValue];
}

- (NSString *)frequencyUnitForDisplay
{
    return [self frequencyUnitForDisplay:self.frequencyUnitValue];
}

- (NavigationNodeFrequencyUnit)closeUnitValue
{
    return [self.closeUnit integerValue];
}

- (void)setCloseUnitValue:(NavigationNodeFrequencyUnit)closeUnitValue
{
    self.closeUnit = [NSNumber numberWithInteger:closeUnitValue];
}

- (NSString *)closeUnitForDisplay
{
    return [self frequencyUnitForDisplay:self.closeUnitValue];
}

- (NSString *)frequencyUnitForDisplay:(NavigationNodeFrequencyUnit)unitValue
{
    NSString *string = nil;
    switch (unitValue) {
        case NavigationNodeFrequencyUnit_None:
            // nothing
            break;
        case NavigationNodeFrequencyUnit_Hourly:
            string = @"Hours";
            break;
        case NavigationNodeFrequencyUnit_Daily:
            string = @"Days";
            break;
        case NavigationNodeFrequencyUnit_Weekly:
            string = @"Weeks";
            break;
        case NavigationNodeFrequencyUnit_Monthly:
            string = @"Months";
            break;
    }
    return string;
}

- (BOOL)isRequired
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationNodeFlagsRequired];
}

- (void)setRequiredFlag:(BOOL)requiredFlag
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationNodeFlagsRequired to:requiredFlag]];
}

- (BOOL)hidesStatusIndicator
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:NavigationNodeHidesStatus];
}

- (void)setHidesStatusIndicator:(BOOL)hidesStatusIndicator
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:NavigationNodeHidesStatus to:hidesStatusIndicator]];
}

- (NSArray *)sortedSubnodes
{
    return [self.subnodes.allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
}

// IAP: if the selected wound woundType matches, then tappig the node should require IAP
- (BOOL)requiresIAPForWoundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return NO;
    }
    // else
    NSRange aRange = [self.woundTypeCodes rangeOfString:[[woundType.woundTypeCode stringValue] stringByAppendingString:@","]];
    return aRange.length > 0;
}

- (void)updateFromNavigationNode:(WMNavigationNode *)navigationNode
      targetManagedObjectContext:(NSManagedObjectContext *)targetManagedObjectContext
          targetPersistenceStore:(NSPersistentStore *)targetStore
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:targetManagedObjectContext];
    NSDictionary *attributesByName = entityDescription.attributesByName;
    for (NSString *key in attributesByName) {
        id value = [navigationNode valueForKey:key];
        [self setValue:value forKey:key];
    }
    // update subnodes
    __block NSSet *subnodes = nil;
    [[navigationNode managedObjectContext] performBlockAndWait:^{
        subnodes = navigationNode.subnodes;
    }];
    for (WMNavigationNode *subnode in subnodes) {
        __block NSString *title = nil;
        [[navigationNode managedObjectContext] performBlockAndWait:^{
            title = subnode.title;
        }];
        WMNavigationNode *subnode2 = [WMNavigationNode nodeForTitle:title
                                                              stage:self.stage
                                                         parentNode:self
                                                             create:YES
                                               managedObjectContext:targetManagedObjectContext
                                                    persistentStore:targetStore];
        [subnode2 updateFromNavigationNode:subnode
                targetManagedObjectContext:targetManagedObjectContext
                    targetPersistenceStore:targetStore];
    }
}

+ (WMNavigationNode *)updateNodeFromDictionary:(NSDictionary *)dictionary
                                         stage:(WMNavigationStage *)stage
                                    parentNode:(WMNavigationNode *)parentNode
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMNavigationNode *navigationNode = [WMNavigationNode nodeForTitle:title
                                                                stage:stage
                                                           parentNode:parentNode
                                                               create:create
                                                 managedObjectContext:managedObjectContext
                                                      persistentStore:store];
    if (nil == navigationNode) {
        return nil;
    }
    // else
    navigationNode.taskIdentifier = [dictionary objectForKey:@"taskIdentifier"];
    navigationNode.activeFlag = [dictionary objectForKey:@"activeFlag"];
    navigationNode.disabledFlag = [dictionary objectForKey:@"disabledFlag"];
    navigationNode.requiredFlag = [[dictionary objectForKey:@"requiredFlag"] boolValue];
    navigationNode.displayTitle = [dictionary objectForKey:@"displayTitle"];
    navigationNode.icon = [dictionary objectForKey:@"icon"];
    id number = [dictionary objectForKey:@"frequencyUnit"];
    if (nil != number) {
        navigationNode.frequencyUnit = number;
    }
    number = [dictionary objectForKey:@"frequencyValue"];
    if (nil != number) {
        navigationNode.frequencyValue = number;
    }
    number = [dictionary objectForKey:@"closeUnit"];
    if (nil != number) {
        navigationNode.closeUnit = number;
    }
    number = [dictionary objectForKey:@"closeValue"];
    if (nil != number) {
        navigationNode.closeValue = number;
    }
    number = [dictionary objectForKey:@"requiresPatientFlag"];
    if (nil != number) {
        navigationNode.requiresPatientFlag = number;
    }
    number = [dictionary objectForKey:@"requiresWoundFlag"];
    if (nil != number) {
        navigationNode.requiresWoundFlag = number;
    }
    number = [dictionary objectForKey:@"requiresWoundPhotoFlag"];
    if (nil != number) {
        navigationNode.requiresWoundPhotoFlag = number;
    }
    navigationNode.sortRank = [dictionary objectForKey:@"sortRank"];
    navigationNode.userSortRank = navigationNode.sortRank;
    navigationNode.desc = [dictionary objectForKey:@"desc"];
    id object = [dictionary objectForKey:@"hidesStatusIndicator"];
    if (nil != object) {
        navigationNode.hidesStatusIndicator = [object boolValue];
    }
    id iapIdentifier = [dictionary objectForKey:@"iapIdentifier"];
    if ([iapIdentifier isKindOfClass:[NSString class]]) {
        navigationNode.iapIdentifier = iapIdentifier;
    }
    id woundTypes = [dictionary objectForKey:@"woundTypes"];
    if ([woundTypes isKindOfClass:[NSString class]]) {
        // make sure we end in , for matching
        if (![woundTypes hasSuffix:@","]) {
            woundTypes = [woundTypes stringByAppendingString:@","];
        }
        navigationNode.woundTypeCodes = woundTypes;
    }
    // save node before attempting to form relationship with subnode
    NSError *error = nil;
    [managedObjectContext saveAndWait:&error];
    [WMUtilities logError:error];
    id subnodes = [dictionary objectForKey:@"subnodes"];
    if ([subnodes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in subnodes) {
            [WMNavigationNode updateNodeFromDictionary:d
                                                 stage:stage
                                            parentNode:navigationNode
                                                create:YES
                                  managedObjectContext:managedObjectContext
                                       persistentStore:store];
        }
    }
    return navigationNode;
}

+ (NSArray *)patientNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patientFlag == YES"]];
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

+ (void)seedPatientNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // select
    WMNavigationNode *navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
    navigationNode.activeFlag = @YES;
    navigationNode.desc = @"Select patient from patient list";
    navigationNode.disabledFlag = @NO;
    navigationNode.displayTitle = @"Select Patient";
    navigationNode.icon = @"patient_select";
    navigationNode.patientFlag = @YES;
    navigationNode.sortRank = @1;
    navigationNode.taskIdentifier = [NSNumber numberWithInt:kSelectPatientNode];
    navigationNode.title = @"Select";
    navigationNode.woundFlag = @NO;
    navigationNode.hidesStatusIndicator = YES;
    // edit
    navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
    navigationNode.activeFlag = @YES;
    navigationNode.desc = @"Edit current patient";
    navigationNode.disabledFlag = @NO;
    navigationNode.displayTitle = @"Edit Patient";
    navigationNode.icon = @"patient_edit";
    navigationNode.patientFlag = @YES;
    navigationNode.sortRank = @2;
    navigationNode.taskIdentifier = [NSNumber numberWithInt:kEditPatientNode];
    navigationNode.title = @"Edit";
    navigationNode.woundFlag = @NO;
    navigationNode.hidesStatusIndicator = YES;
    // add
    navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
    navigationNode.activeFlag = @YES;
    navigationNode.desc = @"Add a new patient";
    navigationNode.disabledFlag = @NO;
    navigationNode.displayTitle = @"Add Patient";
    navigationNode.icon = @"patient_add";
    navigationNode.patientFlag = @YES;
    navigationNode.sortRank = @0;
    navigationNode.taskIdentifier = [NSNumber numberWithInt:kAddPatientNode];
    navigationNode.title = @"Add";
    navigationNode.woundFlag = @NO;
    navigationNode.hidesStatusIndicator = YES;
}

+ (NSArray *)woundNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"woundFlag == YES"]];
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

+ (void)seedWoundNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // select
    WMNavigationNode *navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
    navigationNode.activeFlag = @YES;
    navigationNode.desc = @"Select wound from identified wounds";
    navigationNode.disabledFlag = @NO;
    navigationNode.displayTitle = @"Select Wound";
    navigationNode.icon = @"wound_select";
    navigationNode.patientFlag = @NO;
    navigationNode.sortRank = @1;
    navigationNode.taskIdentifier = [NSNumber numberWithInt:kSelectWoundNode];
    navigationNode.title = @"Select";
    navigationNode.woundFlag = @YES;
    navigationNode.hidesStatusIndicator = YES;
    // edit
    navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
    navigationNode.activeFlag = @YES;
    navigationNode.desc = @"Edit current wound";
    navigationNode.disabledFlag = @NO;
    navigationNode.displayTitle = @"Edit Wound";
    navigationNode.icon = @"wound_edit";
    navigationNode.patientFlag = @NO;
    navigationNode.sortRank = @2;
    navigationNode.taskIdentifier = [NSNumber numberWithInt:kEditWoundNode];
    navigationNode.title = @"Edit";
    navigationNode.woundFlag = @YES;
    navigationNode.hidesStatusIndicator = YES;
    // add
    navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
    navigationNode.activeFlag = @YES;
    navigationNode.desc = @"Add a new wound";
    navigationNode.disabledFlag = @NO;
    navigationNode.displayTitle = @"Add Wound";
    navigationNode.icon = @"wound_add";
    navigationNode.patientFlag = @NO;
    navigationNode.sortRank = @0;
    navigationNode.taskIdentifier = [NSNumber numberWithInt:kAddWoundNode];
    navigationNode.title = @"Add";
    navigationNode.woundFlag = @YES;
    navigationNode.hidesStatusIndicator = YES;
}

+ (WMNavigationNode *)navigationNodeForTaskIdentifier:(NSInteger)navigationNodeIdentifier
                               constrainToPatientFlag:(BOOL)constrainToPatientFlag
                                 constrainToWoundFlag:(BOOL)constrainToWoundFlag
                                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                      persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskIdentifier == %d", navigationNodeIdentifier];
    if (constrainToPatientFlag) {
        predicate = [NSPredicate predicateWithFormat:@"patientFlag == YES AND taskIdentifier == %d", navigationNodeIdentifier];
    } else if (constrainToWoundFlag) {
        predicate = [NSPredicate predicateWithFormat:@"woundFlag == YES AND taskIdentifier == %d", navigationNodeIdentifier];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return [array lastObject];
}

+ (WMNavigationNode *)addPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    return [self navigationNodeForTaskIdentifier:kAddPatientNode
                          constrainToPatientFlag:YES
                            constrainToWoundFlag:NO
                            managedObjectContext:managedObjectContext persistentStore:store];
}

+ (WMNavigationNode *)selectPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    return [self navigationNodeForTaskIdentifier:kSelectPatientNode
                          constrainToPatientFlag:YES
                            constrainToWoundFlag:NO
                            managedObjectContext:managedObjectContext
                                 persistentStore:store];
}

+ (WMNavigationNode *)editPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    return [self navigationNodeForTaskIdentifier:kEditPatientNode
                          constrainToPatientFlag:YES
                            constrainToWoundFlag:NO
                            managedObjectContext:managedObjectContext
                                 persistentStore:store];
}

+ (WMNavigationNode *)addWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    return [self navigationNodeForTaskIdentifier:kAddWoundNode
                          constrainToPatientFlag:NO
                            constrainToWoundFlag:YES
                            managedObjectContext:managedObjectContext
                                 persistentStore:store];
}

+ (WMNavigationNode *)selectWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    return [self navigationNodeForTaskIdentifier:kSelectWoundNode
                          constrainToPatientFlag:NO
                            constrainToWoundFlag:YES
                            managedObjectContext:managedObjectContext
                                 persistentStore:store];
}

+ (WMNavigationNode *)editWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    return [self navigationNodeForTaskIdentifier:kEditWoundNode
                          constrainToPatientFlag:NO
                            constrainToWoundFlag:YES
                            managedObjectContext:managedObjectContext
                                 persistentStore:store];
}

+ (WMNavigationNode *)browsePhotosNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d", kBrowsePhotosNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.activeFlag = @YES;
        navigationNode.desc = @"Review photos of selected wound.";
        navigationNode.disabledFlag = @NO;
        navigationNode.displayTitle = @"Browse";
        navigationNode.icon = @"photos";
        navigationNode.patientFlag = @NO;
        navigationNode.woundFlag = @NO;
        navigationNode.sortRank = @0;
        navigationNode.taskIdentifier = [NSNumber numberWithInt:kBrowsePhotosNode];
        navigationNode.title = @"Browse Photos";
    }
    // else
    return navigationNode;
}

+ (WMNavigationNode *)viewGraphsNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d", kViewGraphsNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.activeFlag = @YES;
        navigationNode.desc = @"Review graphs of measurements for selected wound.";
        navigationNode.disabledFlag = @NO;
        navigationNode.displayTitle = @"Graph";
        navigationNode.icon = @"graph";
        navigationNode.patientFlag = @NO;
        navigationNode.woundFlag = @NO;
        navigationNode.sortRank = @1;
        navigationNode.taskIdentifier = [NSNumber numberWithInt:kViewGraphsNode];
        navigationNode.title = @"View Graphs";
    }
    // else
    return navigationNode;
}

+ (WMNavigationNode *)shareNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d", kShareNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.activeFlag = @YES;
        navigationNode.desc = @"Share patient record via email, print, or EMR.";
        navigationNode.disabledFlag = @NO;
        navigationNode.displayTitle = @"Share";
        navigationNode.icon = @"share";
        navigationNode.patientFlag = @NO;
        navigationNode.woundFlag = @NO;
        navigationNode.sortRank = @2;
        navigationNode.taskIdentifier = [NSNumber numberWithInt:kShareNode];
        navigationNode.title = @"Share Patient Record";
        // TODO: add subnodes
        
    }
    // else
    return navigationNode;
}

+ (WMNavigationNode *)initialStageNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d", kInitialStageNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.activeFlag = @YES;
        navigationNode.desc = @"Initial workup stage for new patient.";
        navigationNode.disabledFlag = @NO;
        navigationNode.displayTitle = @"Initial";
        navigationNode.icon = @"ui_graph.png";
        navigationNode.patientFlag = @NO;
        navigationNode.woundFlag = @NO;
        navigationNode.sortRank = @0;
        navigationNode.taskIdentifier = [NSNumber numberWithInt:kInitialStageNode];
        navigationNode.title = @"Initial Workup";
    }
    // else
    return navigationNode;
}

+ (WMNavigationNode *)followupStageNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d", kFollowupStageNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.activeFlag = @YES;
        navigationNode.desc = @"Follow-up stage for revisiting an existing patient.";
        navigationNode.disabledFlag = @NO;
        navigationNode.displayTitle = @"Follow Up";
        navigationNode.icon = @"ui_graph.png";
        navigationNode.patientFlag = @NO;
        navigationNode.woundFlag = @NO;
        navigationNode.sortRank = @0;
        navigationNode.taskIdentifier = [NSNumber numberWithInt:kFollowupStageNode];
        navigationNode.title = @"Follow Up";
    }
    // else
    return navigationNode;
}

+ (WMNavigationNode *)dischargeStageNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d", kDischargeStageNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.activeFlag = @YES;
        navigationNode.desc = @"Discharge stage for an existing patient.";
        navigationNode.disabledFlag = @NO;
        navigationNode.displayTitle = @"Discharge";
        navigationNode.icon = @"ui_graph";
        navigationNode.patientFlag = @NO;
        navigationNode.woundFlag = @NO;
        navigationNode.sortRank = @0;
        navigationNode.taskIdentifier = [NSNumber numberWithInt:kDischargeStageNode];
        navigationNode.title = @"Discharge";
    }
    // else
    return navigationNode;
}

+ (WMNavigationNode *)carePlanNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d", kCarePlanNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.activeFlag = @YES;
        navigationNode.desc = @"Care Plan";
        navigationNode.disabledFlag = @NO;
        navigationNode.displayTitle = @"Care Plan";
        navigationNode.icon = @"careplan";
        navigationNode.patientFlag = @NO;
        navigationNode.woundFlag = @NO;
        navigationNode.sortRank = @0;
        navigationNode.taskIdentifier = @(kCarePlanNode);
        navigationNode.title = @"Care Plan";
        navigationNode.requiresPatientFlag = @YES;
        navigationNode.requiresWoundFlag = @NO;
        navigationNode.requiresWoundPhotoFlag = @NO;
    }
    // else
    return navigationNode;
}

+ (NSArray *)sortedRootNodesForStage:(WMNavigationStage *)navigationStage
{
    NSManagedObjectContext *managedObjectContext = [navigationStage managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"stage == %@ AND parentNode == nil", navigationStage]];
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

+ (WMNavigationNode *)nodeForTitle:(NSString *)title
                             stage:(WMNavigationStage *)stage
                        parentNode:(WMNavigationNode *)parentNode
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   persistentStore:(NSPersistentStore *)store
{
    stage = (WMNavigationStage *)[managedObjectContext objectWithID:[stage objectID]];
    if (nil != parentNode) {
        parentNode = (WMNavigationNode *)[managedObjectContext objectWithID:[parentNode objectID]];
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND stage == %@ AND parentNode == %@", title, stage, parentNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (create && nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.title = title;
        navigationNode.stage = stage;
        navigationNode.parentNode = parentNode;
    }
    return navigationNode;
}

+ (WMNavigationNode *)nodeForIdentifier:(NSInteger)taskIdentifier
                                  stage:(WMNavigationStage *)stage
                             parentNode:(WMNavigationNode *)parentNode
                                 create:(BOOL)create
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store
{
    stage = (WMNavigationStage *)[managedObjectContext objectWithID:[stage objectID]];
    if (nil != parentNode) {
        parentNode = (WMNavigationNode *)[managedObjectContext objectWithID:[parentNode objectID]];
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %d AND stage == %@ AND parentNode == %@", taskIdentifier, stage, parentNode]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMNavigationNode *navigationNode = [array lastObject];
    if (create && nil == navigationNode) {
        navigationNode = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        navigationNode.taskIdentifier = [NSNumber numberWithInteger:taskIdentifier];
        navigationNode.stage = stage;
        navigationNode.parentNode = parentNode;
    }
    return navigationNode;
}

@end

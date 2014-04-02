#import "WMInterventionStatus.h"
#import "WMInterventionStatusJoin.h"
#import "WMUtilities.h"

NSString * const kInterventionStatusPlanned = @"Planned";
NSString * const kInterventionStatusInProcess = @"In Process";
NSString * const kInterventionStatusCompleted = @"Completed";
NSString * const kInterventionStatusCancelled = @"Cancelled";
NSString * const kInterventionStatusDiscontinue = @"Discontinued";
NSString * const kInterventionStatusNotAdopted = @"Not Adopted";


@interface WMInterventionStatus ()

// Private interface goes here.

@end


@implementation WMInterventionStatus

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)isActive
{
    return [self.activeFlag boolValue];
}

- (BOOL)isInProcess
{
    return [self.title isEqualToString:kInterventionStatusInProcess];
}

- (BOOL)canUpdateToStatus:(WMInterventionStatus *)interventionStatus
{
    return [[self.toStatusJoins valueForKeyPath:@"toStatus"] containsObject:interventionStatus];
}

+ (WMInterventionStatus *)initialInterventionStatus:(NSManagedObjectContext *)managedObjectContext
{
    return [self interventionStatusForTitle:kInterventionStatusPlanned create:NO managedObjectContext:managedObjectContext];
}

+ (WMInterventionStatus *)completedInterventionStatus:(NSManagedObjectContext *)managedObjectContext
{
    return [self interventionStatusForTitle:kInterventionStatusCompleted create:NO managedObjectContext:managedObjectContext];
}

+ (WMInterventionStatus *)interventionStatusForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMInterventionStatus *interventionStatus = [WMInterventionStatus MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == interventionStatus) {
        interventionStatus = [WMInterventionStatus MR_createInContext:managedObjectContext];
        interventionStatus.title = title;
    }
    return interventionStatus;
}

+ (WMInterventionStatus *)updateInterventionFromDictionary:(NSDictionary *)dictionary
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMInterventionStatus *interventionStatus = [self interventionStatusForTitle:title
                                                                         create:YES
                                                           managedObjectContext:managedObjectContext];
    interventionStatus.activeFlag = [dictionary objectForKey:@"activeFlag"];
    interventionStatus.definition = [dictionary objectForKey:@"definition"];
    interventionStatus.loincCode = [dictionary objectForKey:@"loincCode"];
    interventionStatus.snomedCID = [dictionary objectForKey:@"snomedCID"];
    interventionStatus.snomedFSN = [dictionary objectForKey:@"snomedFSN"];
    interventionStatus.sortRank = [dictionary objectForKey:@"sortRank"];
    return interventionStatus;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler;
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"InterventionStatus" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"InterventionStatus.plist file not found");
		return;
	}
    // else count
    if ([WMInterventionStatus MR_countOfEntitiesWithContext:managedObjectContext] > 0) {
        return;
    }
    // else load
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSDictionary class]], @"Property list file did not return a dictionary, class was %@", NSStringFromClass([propertyList class]));
        NSArray *array = [propertyList objectForKey:@"Statuses"];
        NSMutableSet *objectIDs = [[NSMutableSet alloc] init];
        for (NSDictionary *dictionary in array) {
            WMInterventionStatus *interventionStatus = [self updateInterventionFromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[interventionStatus objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[interventionStatus objectID]];
        }
        if (completionHandler) {
            completionHandler(nil, [objectIDs allObjects], [WMInterventionStatus entityName]);
        }
        objectIDs = [[NSMutableSet alloc] init];
        array = [propertyList objectForKey:@"Joins"];
        for (NSDictionary *dictionary in array) {
            NSString *title = [[dictionary allKeys] lastObject];
            WMInterventionStatus *fromStatus = [WMInterventionStatus interventionStatusForTitle:title
                                                                                         create:NO
                                                                           managedObjectContext:managedObjectContext];
            NSAssert1(nil != fromStatus, @"No WMInterventionStatus for title %@", title);
            NSArray *values = [[[dictionary allValues] lastObject] componentsSeparatedByString:@","];
            for (NSString *value in values) {
                WMInterventionStatus *toStatus = [WMInterventionStatus interventionStatusForTitle:value
                                                                                           create:NO
                                                                             managedObjectContext:managedObjectContext];
                NSAssert1(nil != toStatus, @"No WMInterventionStatus for title %@", value);
                WMInterventionStatusJoin *interventionStatusJoin = [WMInterventionStatusJoin interventionStatusJoinFromStatus:fromStatus
                                                                                                                     toStatus:toStatus
                                                                                                                       create:YES
                                                                                                         managedObjectContext:managedObjectContext];
                [managedObjectContext MR_saveOnlySelfAndWait];
                NSAssert(![[interventionStatusJoin objectID] isTemporaryID], @"Expect a permanent objectID");
                [objectIDs addObject:[interventionStatusJoin objectID]];
            }
            if (completionHandler) {
                completionHandler(nil, [objectIDs allObjects], [WMInterventionStatusJoin entityName]);
            }
        }
    }
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"activeFlagValue",
                                                            @"flagsValue",
                                                            @"snomedCIDValue",
                                                            @"sortRankValue",
                                                            @"isActive",
                                                            @"isInProcess"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMInterventionStatusRelationships.carePlanGroups,
                                                            WMInterventionStatusRelationships.deviceGroups,
                                                            WMInterventionStatusRelationships.measurementGroups,
                                                            WMInterventionStatusRelationships.medicationGroups,
                                                            WMInterventionStatusRelationships.psychoSocialGroups,
                                                            WMInterventionStatusRelationships.skinAssessmentGroups,
                                                            WMInterventionStatusRelationships.treatmentGroups]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMInterventionStatus attributeNamesNotToSerialize] containsObject:propertyName] || [[WMInterventionStatus relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMInterventionStatus relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

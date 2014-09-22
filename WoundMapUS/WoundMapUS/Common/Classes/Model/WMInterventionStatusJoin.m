#import "WMInterventionStatusJoin.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMInterventionStatusJoin ()

// Private interface goes here.

@end


@implementation WMInterventionStatusJoin

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMInterventionStatusJoin *)interventionStatusJoinFromStatus:(WMInterventionStatus *)fromStatus
                                                      toStatus:(WMInterventionStatus *)toStatus
                                                        create:(BOOL)create
                                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    fromStatus = (WMInterventionStatus *)[managedObjectContext objectWithID:[fromStatus objectID]];
    toStatus = (WMInterventionStatus *)[managedObjectContext objectWithID:[toStatus objectID]];
    WMInterventionStatusJoin *interventionStatusJoin = [WMInterventionStatusJoin MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fromStatus == %@ AND toStatus == %@", fromStatus, toStatus]
                                                                                                 inContext:managedObjectContext];
    if (create && nil == interventionStatusJoin) {
        interventionStatusJoin = [WMInterventionStatusJoin MR_createInContext:managedObjectContext];
        interventionStatusJoin.fromStatus = fromStatus;
        interventionStatusJoin.toStatus = toStatus;
    }
    return interventionStatusJoin;
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"aggregator", @"requireUpdatesFromCloud"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMInterventionStatusJoinRelationships.fromStatus, WMInterventionStatusJoinRelationships.toStatus]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMInterventionStatusJoin attributeNamesNotToSerialize] containsObject:propertyName] || [[WMInterventionStatusJoin relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMInterventionStatusJoin relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}


@end

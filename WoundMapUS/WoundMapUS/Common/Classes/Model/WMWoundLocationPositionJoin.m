#import "WMWoundLocationPositionJoin.h"
#import "WMWoundLocation.h"
#import "WMWoundPosition.h"
#import "WMUtilities.h"

@interface WMWoundLocationPositionJoin ()

// Private interface goes here.

@end


@implementation WMWoundLocationPositionJoin

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMWoundLocationPositionJoin *)joinForLocation:(WMWoundLocation *)location
                                       positions:(NSSet *)positions
                                          create:(BOOL)create
{
    NSManagedObjectContext *managedObjectContext = [location managedObjectContext];
    WMWoundLocationPositionJoin *join = [WMWoundLocationPositionJoin MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"location == %@ AND positions CONTAINS (%@)", location, [positions anyObject]]
                                                                                     inContext:managedObjectContext];
    if (create && nil == join) {
        join = [WMWoundLocationPositionJoin MR_createInContext:managedObjectContext];
        join.location = location;
        join.positions = positions;
    }
    return join;
}

- (NSArray *)sortedPositions
{
    return [[self.positions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
}

- (WMWoundPosition *)positionAtIndex:(NSInteger)index
{
    return [self.sortedPositions objectAtIndex:index];
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                        @"sortRankValue",
                                        @"sortedPositions",
                                        @"groupValueTypeCode",
                                        @"title",
                                        @"unit",
                                        @"value",
                                        @"optionsArray",
                                        @"secondaryOptionsArray",
                                        @"interventionEvents",
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundLocationPositionJoin attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundLocationPositionJoin relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundLocationPositionJoin relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return [[[self.positions anyObject] valueTypeCode] intValue];
}

- (NSString *)title
{
    return self.location.title;
}

- (void)setTitle:(NSString *)title
{
}


- (NSString *)placeHolder
{
    return nil;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    
}

- (NSString *)unit
{
    return nil;
}

- (void)setUnit:(NSString *)unit
{
}

- (id)value
{
    return nil;
}

- (void)setValue:(id)value
{
}

- (NSArray *)optionsArray
{
    NSArray *sortedOptions = [[self.positions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    return [sortedOptions valueForKeyPath:@"title"];
}

- (NSArray *)secondaryOptionsArray
{
    NSArray *sortedOptions = [[self.positions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    return [sortedOptions valueForKeyPath:@"commonTitle"];
}

@end

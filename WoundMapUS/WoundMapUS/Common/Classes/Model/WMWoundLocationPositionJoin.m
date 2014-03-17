#import "WMWoundLocationPositionJoin.h"
#import "WMWoundLocation.h"
#import "WMWoundPosition.h"
#import "WMUtilities.h"

@interface WMWoundLocationPositionJoin ()

// Private interface goes here.

@end


@implementation WMWoundLocationPositionJoin

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundLocationPositionJoin *join = [[WMWoundLocationPositionJoin alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundLocationPositionJoin" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:join toPersistentStore:store];
	}
    // get a permanent objectID
	return join;
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

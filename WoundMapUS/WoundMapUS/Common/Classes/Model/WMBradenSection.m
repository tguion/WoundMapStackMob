#import "WMBradenSection.h"
#import "WMBradenScale.h"
#import "WMBradenCell.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMBradenSection ()

// Private interface goes here.

@end


@implementation WMBradenSection

+ (id)instanceWithBradenScale:(WMBradenScale *)bradenScale
		 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
			  persistentStore:(NSPersistentStore *)store
{
    NSAssert([[bradenScale managedObjectContext] isEqual:managedObjectContext], @"Wrong managedObjectContext");
    WMBradenSection *bradenSection = [[WMBradenSection alloc] initWithEntity:[NSEntityDescription entityForName:@"WMBradenSection" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	bradenSection.bradenScale = bradenScale;
	if (store) {
		[managedObjectContext assignObject:bradenSection toPersistentStore:store];
	}
    [bradenSection setValue:[bradenSection assignObjectId] forKey:[bradenSection primaryKeyField]];
	return bradenSection;
}

+ (WMBradenSection *)bradenSectionBradenScale:(WMBradenScale *)bradenScale sortRank:(NSInteger)sortRank
{
    NSManagedObjectContext *managedObjectContext = [bradenScale managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMBradenSection" inManagedObjectContext:managedObjectContext]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"bradenScale == %@ AND sortRank == %d", bradenScale, sortRank]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
        return nil;
    }
	// else
	NSAssert1([array count] < 2, @"More than one WCBradenSection for sortRank %d", sortRank);
	return (WMBradenSection *)[array lastObject];
}

- (BOOL)isScored
{
    return nil != self.selectedCell;
}

- (BOOL)isScoredCalculated
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WCBradenCell" inManagedObjectContext:managedObjectContext]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"section == %@ AND selectedFlag == YES", self]];
    NSError *error = nil;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
	// else
	return (count > 0);
}

- (NSInteger)score
{
    return self.selectedCell.valueValue;
}

- (NSArray *)sortedCells
{
	return [[self.cells allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES]]];
}

- (WMBradenCell *)selectedCell
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selectedFlag == YES"];
    NSArray *array = [[self.cells allObjects] filteredArrayUsingPredicate:predicate];
    return [array lastObject];
}

- (void)setSelectedCell:(WMBradenCell *)selectedCell
{
    [self.cells makeObjectsPerformSelector:@selector(setSelectedFlag:) withObject:@NO];
    selectedCell.selectedFlag = @YES;
}

@end

#import "WMBradenSection.h"
#import "WMBradenScale.h"
#import "WMBradenCell.h"
#import "WMUtilities.h"

@interface WMBradenSection ()

// Private interface goes here.

@end


@implementation WMBradenSection

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (id)instanceWithBradenScale:(WMBradenScale *)bradenScale
{
    WMBradenSection *bradenSection = [WMBradenSection MR_createInContext:[bradenScale managedObjectContext]];
	bradenSection.bradenScale = bradenScale;
	return bradenSection;
}

+ (WMBradenSection *)bradenSectionBradenScale:(WMBradenScale *)bradenScale sortRank:(NSInteger)sortRank
{
    NSManagedObjectContext *managedObjectContext = [bradenScale managedObjectContext];
    return [WMBradenSection MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bradenScale == %@ AND sortRank == %d", bradenScale, sortRank]
                                            inContext:managedObjectContext];
}

- (BOOL)isScored
{
    return nil != self.selectedCell;
}

- (BOOL)isScoredCalculated
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSInteger count = [WMBradenCell MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"section == %@ AND selectedFlag == YES", self] inContext:managedObjectContext];
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

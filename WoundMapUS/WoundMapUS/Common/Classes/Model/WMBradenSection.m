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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"sortRankValue",
                                                            @"isScored",
                                                            @"score",
                                                            @"isClosed",
                                                            @"isScored",
                                                            @"isScoredCalculated",
                                                            @"selectedCell",
                                                            @"sortedCells",
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
    if ([[WMBradenSection attributeNamesNotToSerialize] containsObject:propertyName] || [[WMBradenSection relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMBradenSection relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

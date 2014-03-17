#import "_WMBradenSection.h"

@class WMBradenSection, WMBradenCell;

@interface WMBradenSection : _WMBradenSection {}

+ (id)instanceWithBradenScale:(WMBradenScale *)bradenScale
		 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMBradenSection *)bradenSectionBradenScale:(WMBradenScale *)bradenScale sortRank:(NSInteger)sortRank;

@property (readonly, nonatomic) BOOL isScored;
@property (readonly, nonatomic) BOOL isScoredCalculated;
@property (readonly, nonatomic) NSInteger score;
@property (weak, nonatomic) WMBradenCell *selectedCell;

- (NSArray *)sortedCells;

@end

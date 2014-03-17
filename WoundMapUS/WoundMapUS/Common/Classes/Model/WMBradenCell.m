#import "WMBradenCell.h"
#import "WMBradenSection.h"

@interface WMBradenCell ()

// Private interface goes here.

@end


@implementation WMBradenCell

+ (id)instanceWithBradenSection:(WMBradenSection *)bradenSection
		   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSParameterAssert([bradenSection managedObjectContext] == managedObjectContext);
	WMBradenCell *bradenCell = [WMBradenCell MR_createInContext:managedObjectContext];
	bradenCell.section = bradenSection;
	return bradenCell;
}

- (BOOL)isSelected
{
    return [self.selectedFlag boolValue];
}

@end

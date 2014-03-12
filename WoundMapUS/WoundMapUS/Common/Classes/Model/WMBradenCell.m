#import "WMBradenCell.h"
#import "WMBradenSection.h"

@interface WMBradenCell ()

// Private interface goes here.

@end


@implementation WMBradenCell

+ (id)instanceWithBradenSection:(WMBradenSection *)bradenSection
		   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
				persistentStore:(NSPersistentStore *)store
{
	NSAssert([[bradenSection managedObjectContext] isEqual:managedObjectContext], @"Bad managedObjectContext");
	WMBradenCell *bradenCell = [[WMBradenCell alloc] initWithEntity:[NSEntityDescription entityForName:@"WMBradenCell" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	bradenCell.section = bradenSection;
	if (store) {
		[managedObjectContext assignObject:bradenCell toPersistentStore:store];
	}
	return bradenCell;
}

- (BOOL)isSelected
{
    return [self.selectedFlag boolValue];
}

@end

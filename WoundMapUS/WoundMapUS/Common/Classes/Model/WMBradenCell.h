#import "_WMBradenCell.h"

@class WMBradenSection;

@interface WMBradenCell : _WMBradenCell {}

+ (id)instanceWithBradenSection:(WMBradenSection *)bradenSection
		   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
				persistentStore:(NSPersistentStore *)store;

@property (readonly, nonatomic) BOOL isSelected;

@end

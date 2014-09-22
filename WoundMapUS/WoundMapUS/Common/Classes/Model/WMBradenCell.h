#import "_WMBradenCell.h"
#import "WMFFManagedObject.h"

@class WMBradenSection;

@interface WMBradenCell : _WMBradenCell <WMFFManagedObject> {}

+ (id)instanceWithBradenSection:(WMBradenSection *)bradenSection
		   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (readonly, nonatomic) BOOL isSelected;

@end

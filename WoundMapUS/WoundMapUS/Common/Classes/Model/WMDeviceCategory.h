#import "_WMDeviceCategory.h"

@interface WMDeviceCategory : _WMDeviceCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (WMDeviceCategory *)deviceCategoryForTitle:(NSString *)title
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMDeviceCategory *)deviceCategoryForSortRank:(id)sortRank
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

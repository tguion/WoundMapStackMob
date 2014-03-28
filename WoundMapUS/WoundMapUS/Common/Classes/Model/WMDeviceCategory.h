#import "_WMDeviceCategory.h"
#import "WoundCareProtocols.h"

@interface WMDeviceCategory : _WMDeviceCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler;

+ (WMDeviceCategory *)deviceCategoryForTitle:(NSString *)title
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMDeviceCategory *)deviceCategoryForSortRank:(id)sortRank
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

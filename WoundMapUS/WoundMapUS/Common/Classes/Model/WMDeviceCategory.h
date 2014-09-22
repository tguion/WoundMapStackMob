#import "_WMDeviceCategory.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMDeviceCategory : _WMDeviceCategory <WMFFManagedObject> {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMDeviceCategory *)deviceCategoryForTitle:(NSString *)title
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMDeviceCategory *)deviceCategoryForSortRank:(id)sortRank
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

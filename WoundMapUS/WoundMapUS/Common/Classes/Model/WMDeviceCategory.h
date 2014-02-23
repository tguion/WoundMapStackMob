#import "_WMDeviceCategory.h"

@interface WMDeviceCategory : _WMDeviceCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMDeviceCategory *)deviceCategoryForTitle:(NSString *)title
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store;

+ (WMDeviceCategory *)deviceCategoryForSortRank:(id)sortRank
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                persistentStore:(NSPersistentStore *)store;
@end

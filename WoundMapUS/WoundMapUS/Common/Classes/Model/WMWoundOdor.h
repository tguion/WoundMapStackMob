#import "_WMWoundOdor.h"

@interface WMWoundOdor : _WMWoundOdor {}

+ (WMWoundOdor *)woundOdorForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   persistentStore:(NSPersistentStore *)store;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@end

#import "_WMAmountQualifier.h"

@interface WMAmountQualifier : _WMAmountQualifier {}

+ (WMAmountQualifier *)amountQualifierForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@end

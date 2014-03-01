#import "_WMMedicationCategory.h"

@interface WMMedicationCategory : _WMMedicationCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMMedicationCategory *)medicationCategoryForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     persistentStore:(NSPersistentStore *)store;

+ (WMMedicationCategory *)medicationCategoryForSortRank:(id)sortRank
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                        persistentStore:(NSPersistentStore *)store;

@end

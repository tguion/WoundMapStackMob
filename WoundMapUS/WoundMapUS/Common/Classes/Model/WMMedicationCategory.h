#import "_WMMedicationCategory.h"

@interface WMMedicationCategory : _WMMedicationCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedicationCategory *)medicationCategoryForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedicationCategory *)medicationCategoryForSortRank:(id)sortRank
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

#import "_WMSkinAssessmentCategory.h"

@interface WMSkinAssessmentCategory : _WMSkinAssessmentCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForTitle:(NSString *)title
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                             persistentStore:(NSPersistentStore *)store;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForSortRank:(id)sortRank
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                persistentStore:(NSPersistentStore *)store;

@end

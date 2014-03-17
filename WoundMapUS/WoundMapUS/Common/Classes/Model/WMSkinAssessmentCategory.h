#import "_WMSkinAssessmentCategory.h"

@interface WMSkinAssessmentCategory : _WMSkinAssessmentCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForTitle:(NSString *)title
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForSortRank:(id)sortRank
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

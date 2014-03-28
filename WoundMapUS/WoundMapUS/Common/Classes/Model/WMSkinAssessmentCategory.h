#import "_WMSkinAssessmentCategory.h"
#import "WoundCareProtocols.h"

@interface WMSkinAssessmentCategory : _WMSkinAssessmentCategory {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForTitle:(NSString *)title
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForSortRank:(id)sortRank
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

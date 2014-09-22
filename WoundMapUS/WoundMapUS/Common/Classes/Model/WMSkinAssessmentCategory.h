#import "_WMSkinAssessmentCategory.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMSkinAssessmentCategory : _WMSkinAssessmentCategory <WMFFManagedObject> {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForTitle:(NSString *)title
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForSortRank:(id)sortRank
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

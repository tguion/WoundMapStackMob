#import "_WMNutritionItem.h"
#import "WoundCareProtocols.h"

@interface WMNutritionItem : _WMNutritionItem <AssessmentGroup> {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMNutritionItem *)nutritionItemForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end

#import "_WMNutritionItem.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMNutritionItem : _WMNutritionItem <AssessmentGroup, WMFFManagedObject> {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMNutritionItem *)nutritionItemForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end

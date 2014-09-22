#import "_WMCarePlanCategory.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMWoundType;

@interface WMCarePlanCategory : _WMCarePlanCategory <AssessmentGroup, WMFFManagedObject> {}

@property (nonatomic) BOOL combineKeyAndValue;
@property (nonatomic) BOOL inputValueInline;
@property (nonatomic) BOOL allowMultipleChildSelection;
@property (nonatomic) BOOL skipSelectionIcon;
@property (readonly, nonatomic) BOOL hasSubcategories;
@property (readonly, nonatomic) NSArray *sortedChildernCarePlanCategories;

- (NSString *)combineKeyAndValue:(NSString *)value;
- (void)aggregateSubcategories:(NSMutableSet *)set;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (NSArray *)sortedRootCarePlanCategories:(NSManagedObjectContext *)managedObjectContext;
+ (NSSet *)carePlanCategories:(NSManagedObjectContext *)managedObjectContext;

+ (WMCarePlanCategory *)carePlanCategoryForTitle:(NSString *)title
                                          parent:(WMCarePlanCategory *)parent
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSPredicate *)predicateForParent:(WMCarePlanCategory *)parent woundType:(WMWoundType *)woundType;

@end

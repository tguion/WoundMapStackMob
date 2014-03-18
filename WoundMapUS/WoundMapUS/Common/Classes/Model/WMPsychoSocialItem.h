#import "_WMPsychoSocialItem.h"
#import "WoundCareProtocols.h"

@class WMWoundType;

@interface WMPsychoSocialItem : _WMPsychoSocialItem <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL hasSubItems;
@property (nonatomic) BOOL allowMultipleChildSelection;
@property (readonly, nonatomic) NSInteger updatedScore;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)sortedPsychoSocialItemsForParentItem:(WMPsychoSocialItem *)parentItem
                             managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMPsychoSocialItem *)psychoSocialItemForTitle:(NSString *)title
                                      parentItem:(WMPsychoSocialItem *)parentItem
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSPredicate *)predicateForParent:(WMPsychoSocialItem *)parentItem woundType:(WMWoundType *)woundType;

- (void)aggregatePsychoSocialItems:(NSMutableSet *)set;

@end

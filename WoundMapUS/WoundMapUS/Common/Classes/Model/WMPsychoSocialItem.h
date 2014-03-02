#import "_WMPsychoSocialItem.h"
#import "WoundCareProtocols.h"

@class WMWoundType;

@interface WMPsychoSocialItem : _WMPsychoSocialItem <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL hasSubItems;
@property (nonatomic) BOOL allowMultipleChildSelection;
@property (readonly, nonatomic) NSInteger updatedScore;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (NSArray *)sortedPsychoSocialItemsForParentItem:(WMPsychoSocialItem *)parentItem
                             managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                  persistentStore:(NSPersistentStore *)store;

+ (WMPsychoSocialItem *)psychoSocialItemForTitle:(NSString *)title
                                      parentItem:(WMPsychoSocialItem *)parentItem
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store;

+ (NSPredicate *)predicateForParent:(WMPsychoSocialItem *)parentItem woundType:(WMWoundType *)woundType;

- (void)aggregatePsychoSocialItems:(NSMutableSet *)set;

@end

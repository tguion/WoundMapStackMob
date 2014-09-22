#import "_WMWoundTreatment.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMWoundType;

@interface WMWoundTreatment : _WMWoundTreatment <AssessmentGroup, WMFFManagedObject> {}

@property (nonatomic) BOOL combineKeyAndValue;
@property (nonatomic) BOOL allowMultipleChildSelection;
@property (readonly, nonatomic) BOOL hasChildrenWoundTreatments;
@property (readonly, nonatomic) NSArray *sortedChildrenWoundTreatments;
@property (readonly, nonatomic) BOOL childrenHaveSectionTitles;
@property (nonatomic) BOOL skipSelectionIcon;
@property (nonatomic) BOOL normalizeMeasurements;

- (NSString *)combineKeyAndValue:(NSString *)value;
- (void)aggregateWoundTreatments:(NSMutableSet *)set;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;
+ (void)reportWoundTreatments:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundTreatment *)woundTreatmentForTitle:(NSString *)title
                        parentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)sortedRootWoundTreatments:(NSManagedObjectContext *)managedObjectContext;

+ (NSPredicate *)predicateForParentTreatment:(WMWoundTreatment *)parentWoundTreatment woundType:(WMWoundType *)woundType;

@end

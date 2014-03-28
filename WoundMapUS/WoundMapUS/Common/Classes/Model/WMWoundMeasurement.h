#import "_WMWoundMeasurement.h"
#import "WoundCareProtocols.h"

extern NSString *const kWoundMeasurementTitleDimensions;

@class WMWoundType;

@interface WMWoundMeasurement : _WMWoundMeasurement <AssessmentGroup> {}

@property (nonatomic) BOOL allowMultipleChildSelection;
@property (nonatomic) BOOL normalizeMeasurements;
@property (readonly, nonatomic) BOOL hasChildrenWoundMeasurements;
@property (readonly, nonatomic) BOOL childrenHaveSectionTitles;

- (void)aggregateWoundMeasurements:(NSMutableSet *)set;

+ (NSArray *)graphableMeasurementTitles;
+ (NSRange)graphableRangeForMeasurementTitle:(NSString *)title;

+ (NSArray *)sortedRootWoundMeasurements:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)sortedRootGraphableWoundMeasurements:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundMeasurement *)woundMeasureForTitle:(NSString *)title
                      parentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundMeasurement *)dimensionsWoundMeasurement:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundMeasurement *)underminingTunnelingWoundMeasurement:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler;

+ (NSPredicate *)predicateForParentMeasurement:(WMWoundMeasurement *)parentWoundMeasurement woundType:(WMWoundType *)woundType;

@end

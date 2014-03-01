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
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store;

+ (WMWoundMeasurement *)dimensionsWoundMeasurement:(NSManagedObjectContext *)managedObjectContext
                                   persistentStore:(NSPersistentStore *)store;

+ (WMWoundMeasurement *)underminingTunnelingWoundMeasurement:(NSManagedObjectContext *)managedObjectContext
                                             persistentStore:(NSPersistentStore *)store;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (NSPredicate *)predicateForParentMeasurement:(WMWoundMeasurement *)parentWoundMeasurement woundType:(WMWoundType *)woundType;

@end

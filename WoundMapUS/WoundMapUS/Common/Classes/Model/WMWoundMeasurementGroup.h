#import "_WMWoundMeasurementGroup.h"
#import "WMInterventionEventType.h"

extern NSString * const kDimensionsWoundMeasurementTitle;
extern NSString * const kDimensionWidthWoundMeasurementTitle;
extern NSString * const kDimensionLengthWoundMeasurementTitle;
extern NSString * const kDimensionDepthWoundMeasurementTitle;
extern NSString * const kDimensionUndermineTunnelMeasurementTitle;

@class WMWound, WMWoundPhoto, WMWoundMeasurement, WMWoundMeasurementValue, WMInterventionEvent, WMParticipant;

@interface WMWoundMeasurementGroup : _WMWoundMeasurementGroup {}

+ (WMWoundMeasurementGroup *)woundMeasurementGroupInstanceForWound:(WMWound *)wound woundPhoto:(WMWoundPhoto *)woundPhoto;
+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto;
+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto create:(BOOL)create;
+ (WMWoundMeasurementGroup *)activeWoundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto;
+ (NSDate *)mostRecentWoundMeasurementGroupDateModified:(WMWoundPhoto *)woundPhoto;
+ (NSDate *)mostRecentWoundMeasurementGroupDateModifiedForDimensions:(WMWoundPhoto *)woundPhoto;
+ (NSDate *)mostRecentWoundMeasurementGroupDateCreatedForDimensions:(WMWoundPhoto *)woundPhoto;
+ (NSDate *)mostRecentWoundMeasurementGroupDateModifiedExcludingDimensions:(WMWoundPhoto *)woundPhoto;
+ (NSInteger)closeWoundAssessmentGroupsCreatedBefore:(NSDate *)date
                                               wound:(WMWound *)wound;

+ (BOOL)woundMeasurementGroupsHaveHistoryForWound:(WMWound *)wound;
+ (NSInteger)woundMeasurementGroupsCountForWound:(WMWound *)wound;
+ (NSInteger)woundMeasurementGroupsInactiveCountForWound:(WMWound *)wound;

- (BOOL)hasWoundMeasurementValuesForWoundMeasurementAndChildren:(WMWoundMeasurement *)woundMeasurement;
- (WMWoundMeasurementValue *)woundMeasurementValueForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
                                                               create:(BOOL)create
                                                                value:(id)value;
- (NSArray *)woundMeasurementValuesForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement;
- (void)removeWoundMeasurementValuesForParentWoundMeasurement:(WMWoundMeasurement *)woundMeasurement;
- (WMWoundMeasurement *)woundMeasurementForParentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement;
- (NSArray *)woundMeasurementValuesForParentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement;
- (NSString *)displayValueForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement;

- (void)normalizeInputsForParentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement;

- (WMInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                  title:(NSString *)title
                                              valueFrom:(id)valueFrom
                                                valueTo:(id)valueTo
                                                   type:(WMInterventionEventType *)type
                                            participant:(WMParticipant *)participant
                                                 create:(BOOL)create
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant;

@property (readonly, nonatomic) BOOL isClosed;

@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueWidth;
@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueLength;
@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueDepth;

@property (readonly, nonatomic) BOOL hasInterventionEvents;

@property (readonly, nonatomic) NSArray *woundMeasurementValuesAdded;
@property (readonly, nonatomic) NSArray *woundMeasurementValuesRemoved;

@property (readonly, nonatomic) NSDate *lastWoundMeasurementDate;
@property (readonly, nonatomic) NSDate *dateModifiedExludingMeasurement;
@property (readonly, nonatomic) NSInteger tunnelingValueCount;
@property (readonly, nonatomic) NSInteger underminingValueCount;
@property (readonly, nonatomic) NSSet *valuesFromFetch;


@end

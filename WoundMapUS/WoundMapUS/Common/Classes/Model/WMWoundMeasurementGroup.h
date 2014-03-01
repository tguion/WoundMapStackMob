#import "_WMWoundMeasurementGroup.h"

extern NSString * const kDimensionsWoundMeasurementTitle;
extern NSString * const kDimensionWidthWoundMeasurementTitle;
extern NSString * const kDimensionLengthWoundMeasurementTitle;
extern NSString * const kDimensionDepthWoundMeasurementTitle;
extern NSString * const kDimensionUndermineTunnelMeasurementTitle;

@class WMPatient, WMWound, WMWoundPhoto, WMWoundMeasurement, WMWoundMeasurementValue;

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
                                             patient:(WMPatient *)patient;

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

@property (readonly, nonatomic) BOOL isClosed;

@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueWidth;
@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueLength;
@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueDepth;

@property (readonly, nonatomic) NSDate *lastWoundMeasurementDate;
@property (readonly, nonatomic) NSDate *dateModifiedExludingMeasurement;
@property (readonly, nonatomic) NSInteger tunnelingValueCount;
@property (readonly, nonatomic) NSInteger underminingValueCount;
@property (readonly, nonatomic) NSSet *valuesFromFetch;


@end

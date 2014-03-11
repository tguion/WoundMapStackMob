#import "_WMWound.h"

@class WMWoundPosition, WMWoundLocationPositionJoin, WMWoundPositionValue, WMWoundPhoto;

@interface WMWound : _WMWound {}

+ (NSArray *)pressureUlcerTypeCodes;

+ (instancetype)instanceWithPatient:(WMPatient *)patient;

+ (NSInteger)woundCountForPatient:(WMPatient *)patient;

+ (WMWound *)woundForPatient:(WMPatient *)patient woundFFURL:(NSString *)ffUrl;

+ (NSArray *)sortedWounds:(WMPatient *)patient;

+ (NSInteger)woundPhotoCountForWound:(WMWound *)wound;
+ (NSInteger)woundTreatmentCountForWounds:(NSArray *)wounds;
+ (NSDate *)mostRecentWoundPhotoDateModifiedForWound:(WMWound *)wound;
+ (NSDate *)mostRecentWoundPhotoDateCreatedForWound:(WMWound *)wound;

@property (readonly, nonatomic) NSString *shortName;
@property (readonly, nonatomic) WMWoundPhoto *lastWoundPhoto;
@property (readonly, nonatomic) NSInteger woundPhotosCount;
@property (readonly, nonatomic) NSDictionary *minimumAndMaximumWoundPhotoDates;
@property (readonly, nonatomic) NSArray *sortedWoundPhotos;
@property (readonly, nonatomic) NSArray *sortedWoundPhotoIDs;
@property (readonly, nonatomic) NSArray *sortedWoundMeasurements;
@property (readonly, nonatomic) NSArray *sortedWoundTreatments;
@property (readonly, nonatomic) NSArray *woundTypeForDisplay;
@property (readonly, nonatomic) NSInteger woundPositionCount;
@property (readonly, nonatomic) NSArray *sortedPositionValues;
@property (readonly, nonatomic) NSString *positionValuesForDisplay;
@property (readonly, nonatomic) NSString *woundLocationAndPositionForDisplay;
@property (readonly, nonatomic) WMWoundTreatmentGroup *lastWoundTreatmentGroup;
@property (readonly, nonatomic) NSInteger woundTreatmentGroupCount;

- (NSArray *)sortedWoundMeasurementsAscending:(BOOL)ascending;
- (NSArray *)sortedWoundTreatmentsAscending:(BOOL)ascending;
- (NSArray *)woundPositionValuesForJoin:(WMWoundLocationPositionJoin *)woundPositionJoin
                                  value:(id)value;
- (WMWoundPositionValue *)woundPositionValueForJoin:(WMWoundLocationPositionJoin *)woundPositionJoin
                                             create:(BOOL)create
                                              value:(id)value;
- (WMWoundPositionValue *)woundPositionValueForWoundPosition:(WMWoundPosition *)woundPosition
                                                      create:(BOOL)create
                                                       value:(id)value;

- (WMWoundPhoto *)referenceWoundPhoto:(WMWoundPhoto *)woundPhoto;
- (BOOL)hasPreviousWoundPhoto:(WMWoundPhoto *)woundPhoto;
- (WMWoundPhoto *)woundPhotoForDate:(NSDate *)date;
- (WMWoundTreatmentGroup *)woundTreatmentGroupClosestToDate:(NSDate *)date;

@end

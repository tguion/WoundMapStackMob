#import "_WMWoundMeasurementGroup.h"

extern NSString * const kDimensionsWoundMeasurementTitle;
extern NSString * const kDimensionWidthWoundMeasurementTitle;
extern NSString * const kDimensionLengthWoundMeasurementTitle;
extern NSString * const kDimensionDepthWoundMeasurementTitle;
extern NSString * const kDimensionUndermineTunnelMeasurementTitle;

@class WMWoundMeasurementValue;

@interface WMWoundMeasurementGroup : _WMWoundMeasurementGroup {}

+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto;

+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto create:(BOOL)create;

@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueWidth;
@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueLength;
@property (readonly, nonatomic) WMWoundMeasurementValue *measurementValueDepth;

@end

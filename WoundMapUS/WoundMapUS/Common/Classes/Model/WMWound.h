#import "_WMWound.h"

@interface WMWound : _WMWound {}

+ (instancetype)instanceWithPatient:(WMPatient *)patient;

+ (NSInteger)woundCountForPatient:(WMPatient *)patient;

@property (readonly, nonatomic) NSArray *woundTypeForDisplay;

@end

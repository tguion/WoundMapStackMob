#import "_WMWound.h"

@interface WMWound : _WMWound {}

+ (instancetype)instanceWithPatient:(WMPatient *)patient;

+ (NSInteger)woundCountForPatient:(WMPatient *)patient;

+ (WMWound *)woundForPatient:(WMPatient *)patient woundId:(NSString *)woundId;

@property (readonly, nonatomic) NSArray *woundTypeForDisplay;

@end

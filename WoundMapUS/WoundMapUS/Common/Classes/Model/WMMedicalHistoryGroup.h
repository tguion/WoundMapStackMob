#import "_WMMedicalHistoryGroup.h"
#import "WMFatFractalManager.h"

@class WMMedicalHistoryItem;

@interface WMMedicalHistoryGroup : _WMMedicalHistoryGroup {}

@property (readonly, nonatomic) NSArray *sortedMedicalHistoryValues;
@property (readonly, nonatomic) NSInteger valueCount;

+ (WMMedicalHistoryGroup *)activeMedicalHistoryGroup:(WMPatient *)patient groupCreatedCallback:(WMObjectCallback)groupCallback;

+ (NSSet *)medicalHistoryValuesForMedicalHistoryGroup:(WMMedicalHistoryGroup *)medicalHistoryGroup;
+ (NSInteger)medicalHistoryGroupsCount:(WMPatient *)patient;

- (WMMedicalHistoryValue *)medicalHistoryValueForMedicalHistoryItem:(WMMedicalHistoryItem *)medicalHistoryItem
                                                             create:(BOOL)create
                                                              value:(NSString *)value;

@end

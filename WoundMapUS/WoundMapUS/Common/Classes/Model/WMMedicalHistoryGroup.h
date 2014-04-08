#import "_WMMedicalHistoryGroup.h"

@class WMMedicalHistoryItem;

@interface WMMedicalHistoryGroup : _WMMedicalHistoryGroup {}

@property (readonly, nonatomic) NSArray *sortedMedicalHistoryValues;

+ (WMMedicalHistoryGroup *)activeMedicalHistoryGroup:(WMPatient *)patient;

+ (NSSet *)medicalHistoryValuesForMedicalHistoryGroup:(WMMedicalHistoryGroup *)medicalHistoryGroup;
+ (NSInteger)medicalHistoryGroupsCount:(WMPatient *)patient;

- (WMMedicalHistoryValue *)medicalHistoryValueForMedicalHistoryItem:(WMMedicalHistoryItem *)medicalHistoryItem
                                                             create:(BOOL)create
                                                              value:(NSString *)value;

@end

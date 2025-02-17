#import "_WMMedicalHistoryGroup.h"
#import "WMFatFractalManager.h"
#import "WMFFManagedObject.h"

@class WMMedicalHistoryItem;

@interface WMMedicalHistoryGroup : _WMMedicalHistoryGroup <WMFFManagedObject> {}

@property (readonly, nonatomic) NSArray *sortedMedicalHistoryValues;
@property (readonly, nonatomic) NSInteger valueCount;

+ (WMMedicalHistoryGroup *)activeMedicalHistoryGroup:(WMPatient *)patient;
+ (WMMedicalHistoryGroup *)medicalHistoryGroupForPatient:(WMPatient *)patient;

+ (NSSet *)medicalHistoryValuesForMedicalHistoryGroup:(WMMedicalHistoryGroup *)medicalHistoryGroup;
+ (NSInteger)medicalHistoryGroupsCount:(WMPatient *)patient;

- (WMMedicalHistoryValue *)medicalHistoryValueForMedicalHistoryItem:(WMMedicalHistoryItem *)medicalHistoryItem
                                                             create:(BOOL)create
                                                              value:(NSString *)value;

@end

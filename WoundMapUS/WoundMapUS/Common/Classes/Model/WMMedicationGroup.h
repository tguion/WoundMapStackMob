#import "_WMMedicationGroup.h"
#import "WoundCareProtocols.h"

@class WMPatient;

@interface WMMedicationGroup : _WMMedicationGroup  <AssessmentGroup> {}

@property (readonly, nonatomic) NSArray *sortedMedications;
@property (readonly, nonatomic) NSArray *medicationsInGroup;
@property (readonly, nonatomic) BOOL isClosed;

+ (WMMedicationGroup *)activeMedicationGroup:(WMPatient *)patient;
+ (WMMedicationGroup *)mostRecentOrActiveMedicationGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveMedicationGroupDateModified:(WMPatient *)patient;
+ (NSInteger)closeMedicationGroupsCreatedBefore:(NSDate *)date
                                        patient:(WMPatient *)patient;

+ (BOOL)medicalGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)medicalGroupsCount:(WMPatient *)patient;

+ (NSArray *)sortedMedicationGroups:(WMPatient *)patient;

- (BOOL)removeExcludesOtherValues;
- (void)incrementContinueCount;

@end

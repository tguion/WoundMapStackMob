#import "_WMCarePlanGroup.h"
#import "WoundCareProtocols.h"

@class WMPatient, WMCarePlanValue, WMCarePlanCategory;

@interface WMCarePlanGroup : _WMCarePlanGroup <AssessmentGroup> {}

@property (readonly, nonatomic) NSArray *sortedCarePlanValues;
@property (readonly, nonatomic) BOOL isClosed;

+ (WMCarePlanGroup *)activeCarePlanGroup:(WMPatient *)patient;
+ (WMCarePlanGroup *)mostRecentOrActiveCarePlanGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveCarePlanGroupDateModified:(WMPatient *)patient;
+ (NSInteger)closeCarePlanGroupsCreatedBefore:(NSDate *)date
                                      patient:(WMPatient *)patient;

+ (NSSet *)carePlanValuesForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup;

+ (BOOL)carePlanGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)carePlanGroupsCount:(WMPatient *)patient;

+ (NSArray *)sortedCarePlanGroups:(WMPatient *)patient;

- (WMCarePlanValue *)carePlanValueForPatient:(WMPatient *)patient
                            carePlanCategory:(WMCarePlanCategory *)carePlanCategory
                                      create:(BOOL)create
                                       value:(NSString *)value;

- (WMCarePlanCategory *)carePlanCategoryForParentCategory:(WMCarePlanCategory *)parentCategory;
- (BOOL)hasValueForCategoryOrDescendants:(WMCarePlanCategory *)carePlanCategory;
- (void)removeCarePlanValuesForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory;

- (void)incrementContinueCount;

- (NSInteger)valuesCountForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory;

- (void)refreshData;

@end

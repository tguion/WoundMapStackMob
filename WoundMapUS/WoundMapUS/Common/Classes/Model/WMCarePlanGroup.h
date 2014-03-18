#import "_WMCarePlanGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMCarePlanValue, WMCarePlanCategory, WMCarePlanInterventionEvent, WMParticipant, WMInterventionEventType;

@interface WMCarePlanGroup : _WMCarePlanGroup <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL hasInterventionEvents;
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

- (WMCarePlanValue *)carePlanValueForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory
                                               create:(BOOL)create
                                                value:(NSString *)value;

- (WMCarePlanCategory *)carePlanCategoryForParentCategory:(WMCarePlanCategory *)parentCategory;
- (BOOL)hasValueForCategoryOrDescendants:(WMCarePlanCategory *)carePlanCategory;
- (void)removeCarePlanValuesForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory;

- (WMCarePlanInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                           path:(NSString *)path
                                                          title:(NSString *)title
                                                      valueFrom:(id)valueFrom
                                                        valueTo:(id)valueTo
                                                           type:(WMInterventionEventType *)type
                                                    participant:(WMParticipant *)participant
                                                         create:(BOOL)create
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)createEditEventsForParticipant:(WMParticipant *)participant;
- (void)incrementContinueCount;

- (NSInteger)valuesCountForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory;

- (void)refreshData;

@end

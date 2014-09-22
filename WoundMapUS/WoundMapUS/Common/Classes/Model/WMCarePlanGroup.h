#import "_WMCarePlanGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"
#import "WMFFManagedObject.h"

@class WMPatient, WMCarePlanValue, WMCarePlanCategory, WMInterventionEvent, WMParticipant, WMInterventionEventType;

@interface WMCarePlanGroup : _WMCarePlanGroup <AssessmentGroup, WMFFManagedObject> {}

@property (readonly, nonatomic) BOOL hasInterventionEvents;
@property (readonly, nonatomic) NSArray *sortedCarePlanValues;
@property (readonly, nonatomic) BOOL isClosed;

@property (readonly, nonatomic) NSArray *carePlanValuesAdded;
@property (readonly, nonatomic) NSArray *carePlanValuesRemoved;

+ (WMCarePlanGroup *)activeCarePlanGroup:(WMPatient *)patient;
+ (WMCarePlanGroup *)carePlanGroupForPatient:(WMPatient *)patient;
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
- (NSArray *)removeCarePlanValuesForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory;

- (WMInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                   path:(NSString *)path
                                                  title:(NSString *)title
                                              valueFrom:(id)valueFrom
                                                valueTo:(id)valueTo
                                                   type:(WMInterventionEventType *)type
                                            participant:(WMParticipant *)participant
                                                 create:(BOOL)create
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant;
- (void)incrementContinueCount;

- (NSInteger)valuesCountForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory;

@end

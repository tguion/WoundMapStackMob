#import "_WMSkinAssessmentGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"
#import "WMFFManagedObject.h"

@class WMPatient, WMSkinAssessment, WMSkinAssessmentCategory, WMSkinAssessmentValue, WMInterventionEvent, WMParticipant;

@interface WMSkinAssessmentGroup : _WMSkinAssessmentGroup <AssessmentGroup, WMFFManagedObject> {}

@property (readonly, nonatomic) BOOL isClosed;
@property (readonly, nonatomic) BOOL hasInterventionEvents;
@property (readonly, nonatomic) NSArray *sortedSkinAssessmentValues;
@property (readonly, nonatomic) BOOL hasValues;

@property (readonly, nonatomic) NSArray *skinAssessmentValuesAdded;
@property (readonly, nonatomic) NSArray *skinAssessmentValuesRemoved;

+ (WMSkinAssessmentGroup *)activeSkinAssessmentGroup:(WMPatient *)patient;
+ (WMSkinAssessmentGroup *)mostRecentOrActiveSkinAssessmentGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveSkinAssessmentGroupDateModified:(WMPatient *)patient;
+ (NSInteger)closeSkinAssessmentGroupsCreatedBefore:(NSDate *)date
                                            patient:(WMPatient *)patient;

+ (BOOL)skinAssessmentGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)skinAssessmentGroupsCount:(WMPatient *)patient;

+ (NSArray *)sortedSkinAssessmentGroups:(WMPatient *)patient;

- (WMSkinAssessmentValue *)skinAssessmentValueForSkinAssessment:(WMSkinAssessment *)skinAssessment
                                                         create:(BOOL)create
                                                          value:(id)value;

- (NSArray *)removeSkinAssessmentValuesForCategory:(WMSkinAssessmentCategory *)category;

- (WMInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                  title:(NSString *)title
                                              valueFrom:(id)valueFrom
                                                valueTo:(id)valueTo
                                                   type:(WMInterventionEventType *)type
                                            participant:(WMParticipant *)participant
                                                 create:(BOOL)create
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant;
- (void)incrementContinueCount;

@end

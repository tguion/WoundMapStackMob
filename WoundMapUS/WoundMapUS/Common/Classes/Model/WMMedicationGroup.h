#import "_WMMedicationGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMMedicationInterventionEvent, WMParticipant;

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

- (WMMedicationInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                            title:(NSString *)title
                                                        valueFrom:(id)valueFrom
                                                          valueTo:(id)valueTo
                                                             type:(WMInterventionEventType *)type
                                                      participant:(WMParticipant *)participant
                                                           create:(BOOL)create
                                             managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)createEditEventsForParticipant:(WMParticipant *)participant;
- (void)incrementContinueCount;

@end

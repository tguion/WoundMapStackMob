#import "_WMMedicationGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMInterventionEvent, WMParticipant;

@interface WMMedicationGroup : _WMMedicationGroup  <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL hasInterventionEvents;
@property (readonly, nonatomic) NSArray *sortedMedications;
@property (readonly, nonatomic) NSArray *medicationsInGroup;
@property (readonly, nonatomic) BOOL isClosed;

@property (readonly, nonatomic) NSArray *medicationsAdded;
@property (readonly, nonatomic) NSArray *medicationsRemoved;

+ (WMMedicationGroup *)medicationGroupForPatient:(WMPatient *)patient;
+ (WMMedicationGroup *)activeMedicationGroup:(WMPatient *)patient;
+ (WMMedicationGroup *)mostRecentOrActiveMedicationGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveMedicationGroupDateModified:(WMPatient *)patient;
+ (NSInteger)closeMedicationGroupsCreatedBefore:(NSDate *)date
                                        patient:(WMPatient *)patient;

+ (BOOL)medicalGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)medicalGroupsCount:(WMPatient *)patient;

+ (NSArray *)sortedMedicationGroups:(WMPatient *)patient;

- (BOOL)removeExcludesOtherValues;

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

#import "_WMWoundTreatmentGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMWound, WMWoundTreatment, WMWoundTreatmentValue, WMInterventionEvent, WMParticipant;

@interface WMWoundTreatmentGroup : _WMWoundTreatmentGroup <AssessmentGroup> {}

+ (WMWoundTreatmentGroup *)woundTreatmentGroupForWound:(WMWound *)wound;

+ (BOOL)woundTreatmentGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)woundTreatmentGroupsCount:(WMPatient *)patient;
+ (NSInteger)woundTreatmentGroupsInactiveOrClosedCount:(WMPatient *)patient;

- (BOOL)hasWoundTreatmentValuesForWoundTreatmentAndChildren:(WMWoundTreatment *)woundTreatment;

@property (readonly, nonatomic) BOOL isClosed;
@property (readonly, nonatomic) BOOL hasInterventionEvents;

@property (readonly, nonatomic) NSArray *woundTreatmentValuesAdded;
@property (readonly, nonatomic) NSArray *woundTreatmentValuesRemoved;

- (WMWoundTreatmentValue *)woundTreatmentValueForWoundTreatment:(WMWoundTreatment *)woundTreatment
                                                         create:(BOOL)create
                                                          value:(id)value;

- (void)removeWoundTreatmentValuesForParentWoundTreatment:(WMWoundTreatment *)woundTreatment;
- (WMWoundTreatment *)woundTreatmentForParentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment sectionTitle:(NSString *)sectionTitle;
+ (NSInteger)closeWoundTreatmentGroupsCreatedBefore:(NSDate *)date
                                            patient:(WMPatient *)patient;

+ (NSDate *)mostRecentDateModified:(WMWound *)wound;
+ (WMWoundTreatmentGroup *)activeWoundTreatmentGroupForWound:(WMWound *)wound;

- (NSInteger)valuesCountForWoundTreatment:(WMWoundTreatment *)woundTreatment;

- (WMInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                  title:(NSString *)title
                                              valueFrom:(id)valueFrom
                                                valueTo:(id)valueTo
                                                   type:(WMInterventionEventType *)type
                                            participant:(WMParticipant *)participant
                                                 create:(BOOL)create
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant;

@end

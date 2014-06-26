#import "_WMWoundTreatmentGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMWound, WMWoundTreatment, WMWoundTreatmentValue, WMInterventionEvent, WMParticipant;

@interface WMWoundTreatmentGroup : _WMWoundTreatmentGroup <AssessmentGroup> {}

+ (WMWoundTreatmentGroup *)woundTreatmentGroupForWound:(WMWound *)wound;

+ (BOOL)woundTreatmentGroupsHaveHistory:(WMWound *)wound;
+ (NSInteger)woundTreatmentGroupsCount:(WMWound *)wound;
+ (NSInteger)woundTreatmentGroupsInactiveOrClosedCount:(WMWound *)wound;

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
                                              wound:(WMWound *)wound;

+ (NSDate *)mostRecentDateModified:(WMWound *)wound;
+ (NSDate *)lastWoundTreatmentGroupCreated:(WMPatient *)patient;
+ (WMWoundTreatmentGroup *)activeWoundTreatmentGroupForWound:(WMWound *)wound;

- (NSInteger)valuesCountForWoundTreatment:(WMWoundTreatment *)woundTreatment;

- (void)normalizeInputsForParentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment;

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

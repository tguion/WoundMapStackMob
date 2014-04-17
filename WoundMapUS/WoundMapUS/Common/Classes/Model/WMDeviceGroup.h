#import "_WMDeviceGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMDeviceValue, WMDevice, WMInterventionEvent, WMInterventionEventType, WMParticipant;

@interface WMDeviceGroup : _WMDeviceGroup <AssessmentGroup> {}

@property (readonly, nonatomic) NSArray *devices;
@property (readonly, nonatomic) BOOL hasInterventionEvents;
@property (readonly, nonatomic) NSArray *sortedDeviceValues;
@property (readonly, nonatomic) BOOL isClosed;

@property (readonly, nonatomic) NSArray *deviceValuesAdded;
@property (readonly, nonatomic) NSArray *deviceValuesRemoved;

+ (BOOL)deviceGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)deviceGroupsCount:(WMPatient *)patient;

+ (WMDeviceGroup *)deviceGroupForPatient:(WMPatient *)patient;
+ (WMDeviceGroup *)activeDeviceGroup:(WMPatient *)patient;
+ (WMDeviceGroup *)mostRecentOrActiveDeviceGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveDeviceGroupDateModified:(WMPatient *)patient;
+ (NSInteger)closeDeviceGroupsCreatedBefore:(NSDate *)date
                                    patient:(WMPatient *)patient;

+ (NSArray *)sortedDeviceGroups:(WMPatient *)patient;

- (WMDeviceValue *)deviceValueForDevice:(WMDevice *)device
                                 create:(BOOL)create
                                  value:(NSString *)value;

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

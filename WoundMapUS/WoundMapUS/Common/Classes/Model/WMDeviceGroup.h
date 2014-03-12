#import "_WMDeviceGroup.h"
#import "WoundCareProtocols.h"

@class WMPatient, WMDeviceValue, WMDevice;

@interface WMDeviceGroup : _WMDeviceGroup <AssessmentGroup> {}

@property (readonly, nonatomic) NSArray *devices;
@property (readonly, nonatomic) NSArray *sortedDeviceValues;
@property (readonly, nonatomic) BOOL isClosed;

+ (BOOL)deviceGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)deviceGroupsCount:(WMPatient *)patient;

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
- (void)incrementContinueCount;

@end

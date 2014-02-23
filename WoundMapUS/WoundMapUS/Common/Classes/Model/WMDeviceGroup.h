#import "_WMDeviceGroup.h"
#import "WoundCareProtocols.h"

@class WMDeviceValue, WMDevice;

@interface WMDeviceGroup : _WMDeviceGroup <AssessmentGroup> {}

@property (readonly, nonatomic) NSArray *devices;
@property (readonly, nonatomic) NSArray *sortedDeviceValues;
@property (readonly, nonatomic) BOOL isClosed;

+ (BOOL)deviceGroupsHaveHistory:(NSManagedObjectContext *)managedObjectContext;
+ (NSInteger)deviceGroupsCount:(NSManagedObjectContext *)managedObjectContext;

+ (WMDeviceGroup *)deviceGroupByRevising:(WMDeviceGroup *)deviceGroup
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMDeviceGroup *)activeDeviceGroup:(NSManagedObjectContext *)managedObjectContext;
+ (WMDeviceGroup *)mostRecentOrActiveDeviceGroup:(NSManagedObjectContext *)managedObjectContext;
+ (NSDate *)mostRecentOrActiveDeviceGroupDateModified:(NSManagedObjectContext *)managedObjectContext;
+ (NSInteger)closeDeviceGroupsCreatedBefore:(NSDate *)date
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            persistentStore:(NSPersistentStore *)store;

+ (NSArray *)sortedDeviceGroups:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

- (WMDeviceValue *)deviceValueForDevice:(WMDevice *)device
                                 create:(BOOL)create
                                  value:(NSString *)value
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (BOOL)removeExcludesOtherValues;
- (void)incrementContinueCount;

@end

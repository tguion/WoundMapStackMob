#import "_WMDevice.h"
#import "WoundCareProtocols.h"

@class WMWoundType;

@interface WMDevice : _WMDevice <AssessmentGroup> {}

@property (nonatomic) BOOL exludesOtherValues;

+ (WMDevice *)deviceForTitle:(NSString *)title
                      create:(BOOL)create
        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
             persistentStore:(NSPersistentStore *)store;

+ (WMDevice *)updateDeviceFromDictionary:(NSDictionary *)dictionary
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                         persistentStore:(NSPersistentStore *)store;

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType;

@end

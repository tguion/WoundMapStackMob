#import "_WMDevice.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMWoundType, WMPatient;

@interface WMDevice : _WMDevice <AssessmentGroup, WMFFManagedObject> {}

@property (nonatomic) BOOL exludesOtherValues;

+ (WMDevice *)deviceForTitle:(NSString *)title
                      create:(BOOL)create
        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMDevice *)updateDeviceFromDictionary:(NSDictionary *)dictionary
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType;

@end

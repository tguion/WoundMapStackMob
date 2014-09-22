#import "_WMWoundMeasurementValue.h"
#import "WMFFManagedObject.h"

typedef NS_ENUM(NSUInteger, WoundMeasurementValueType) {
    kWoundMeasurementValueTypeNormal,
    kWoundMeasurementValueTypeTunnel,
    kWoundMeasurementValueTypeUndermine
};

@interface WMWoundMeasurementValue : _WMWoundMeasurementValue <WMFFManagedObject> {}

+ (instancetype)normalWoundMeasurementValue:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)tunnelWoundMeasurementValue:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)undermineWoundMeasurementValue:(NSManagedObjectContext *)managedObjectContext;

@property (readonly, nonatomic) BOOL isTunnelingValue;
@property (readonly, nonatomic) BOOL isUnderminingValue;

@property (readonly) NSString *displayValue;
@property (readonly, nonatomic) NSString *labelText;
@property (readonly, nonatomic) NSString *valueText;

@end

#import "WMWoundMeasurementTunnelValue.h"
#import "StackMob.h"

@interface WMWoundMeasurementTunnelValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementTunnelValue

- (NSString *)labelText
{
    return @"Tunneling";
}

- (NSString *)valueText
{
    return [NSString stringWithFormat:@"%@ O'Clock %@ cm", self.fromOClockValue, ([self.value length] > 0 ? self.value:@"?")];
}

- (NSString *)displayValue
{
    return self.valueText;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.sectionTitle = @"Tunneling";
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurementTunnelValue *woundMeasurementTunnelValue = [[WMWoundMeasurementTunnelValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementTunnelValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurementTunnelValue toPersistentStore:store];
	}
    [woundMeasurementTunnelValue setValue:[woundMeasurementTunnelValue assignObjectId] forKey:[woundMeasurementTunnelValue primaryKeyField]];
	return woundMeasurementTunnelValue;
}

@end

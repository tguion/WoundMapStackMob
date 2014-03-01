#import "WMWoundMeasurementUndermineValue.h"
#import "StackMob.h"

@interface WMWoundMeasurementUndermineValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementUndermineValue

- (NSString *)labelText
{
    return @"Undermining";
}

- (NSString *)valueText
{
    return [NSString stringWithFormat:@"%@-%@ O'Clock %@ cm", self.fromOClockValue, self.toOClockValue, ([self.value length] > 0 ? self.value:@"?")];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurementUndermineValue *woundMeasurementUndermineValue = [[WMWoundMeasurementUndermineValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementUndermineValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurementUndermineValue toPersistentStore:store];
	}
    [woundMeasurementUndermineValue setValue:[woundMeasurementUndermineValue assignObjectId] forKey:[woundMeasurementUndermineValue primaryKeyField]];
	return woundMeasurementUndermineValue;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.sectionTitle = @"Undermining";
}

- (NSString *)displayValue
{
    return self.valueText;
}

@end

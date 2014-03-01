#import "WMWoundMeasurementValue.h"
#import "WMWoundMeasurement.h"
#import "WMAmountQualifier.h"
#import "WMWoundOdor.h"
#import "StackMob.h"

@interface WMWoundMeasurementValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementValue

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurementValue *woundMeasurementValue = [[WMWoundMeasurementValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurementValue toPersistentStore:store];
	}
    [woundMeasurementValue setValue:[woundMeasurementValue assignObjectId] forKey:[woundMeasurementValue primaryKeyField]];
	return woundMeasurementValue;
}

- (NSString *)displayValue
{
    NSString *displayValue = nil;
    if (nil == self.value) {
        displayValue = self.amountQualifier.title;
        if (nil == displayValue) {
            displayValue = self.odor.title;
            if (nil == displayValue) {
                displayValue = self.woundMeasurement.title;
            }
        }
    } else {
        switch (self.woundMeasurement.groupValueTypeCode) {
            case GroupValueTypeCodeInlineExtendsTextField:
                displayValue = [NSString stringWithFormat:@"Extends out %@ cm", self.value];
                break;
            default:
                displayValue = self.value;
                break;
        }
    }
    return displayValue;
}

@end

#import "WMWoundTreatmentValue.h"
#import "StackMob.h"

@interface WMWoundTreatmentValue ()

// Private interface goes here.

@end


@implementation WMWoundTreatmentValue

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundTreatmentValue *woundTreatmentValue = [[WMWoundTreatmentValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundTreatmentValue toPersistentStore:store];
	}
    [woundTreatmentValue setValue:[woundTreatmentValue assignObjectId] forKey:[woundTreatmentValue primaryKeyField]];
	return woundTreatmentValue;
}

@end

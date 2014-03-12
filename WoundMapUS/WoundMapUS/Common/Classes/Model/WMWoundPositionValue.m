#import "WMWoundPositionValue.h"
#import "WMWound.h"
#import "StackMob.h"

@interface WMWoundPositionValue ()

// Private interface goes here.

@end


@implementation WMWoundPositionValue

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundPositionValue *woundPositionValue = [[WMWoundPositionValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundPositionValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundPositionValue toPersistentStore:store];
	}
    [woundPositionValue setValue:[woundPositionValue assignObjectId] forKey:[woundPositionValue primaryKeyField]];
	return woundPositionValue;
}

+ (WMWoundPositionValue *)woundPositionValueForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    WMWoundPositionValue *woundPositionValue = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
    woundPositionValue.wound = wound;
    return woundPositionValue;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end

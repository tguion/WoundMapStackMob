#import "WMWoundLocationValue.h"
#import "WMWound.h"
#import "StackMob.h"

@interface WMWoundLocationValue ()

// Private interface goes here.

@end


@implementation WMWoundLocationValue

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundLocationValue *woundLocationValue = [[WMWoundLocationValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundLocationValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundLocationValue toPersistentStore:store];
	}
    [woundLocationValue setValue:[woundLocationValue assignObjectId] forKey:[woundLocationValue primaryKeyField]];
	return woundLocationValue;
}

+ (WMWoundLocationValue *)woundLocationValueForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    WMWoundLocationValue *woundLocationValue = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
    woundLocationValue.wound = wound;
    return woundLocationValue;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.dateModified = [NSDate date];
}

@end

#import "WMWoundPosition.h"
#import "WMWoundLocation.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    WoundPositionFlagsOptionsInline             = 0,
    WoundPositionFlagsAllowMultipleSelection    = 1,
} WoundPositionFlags;

@interface WMWoundPosition ()

// Private interface goes here.

@end


@implementation WMWoundPosition

- (BOOL)optionsInline
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundPositionFlagsOptionsInline];
}

- (void)setOptionsInline:(BOOL)optionsInline
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundPositionFlagsOptionsInline to:optionsInline]];
}

- (BOOL)allowMultipleSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundPositionFlagsAllowMultipleSelection];
}

- (void)setAllowMultipleSelection:(BOOL)allowMultipleSelection
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundPositionFlagsAllowMultipleSelection to:allowMultipleSelection]];
}

- (BOOL)hasTitle
{
    return [self.title length] > 0;
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundPosition *woundPosition = [[WMWoundPosition alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundPosition" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundPosition toPersistentStore:store];
	}
    [woundPosition setValue:[woundPosition assignObjectId] forKey:[woundPosition primaryKeyField]];
	return woundPosition;
}

+ (WMWoundPosition *)woundPositionForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                           persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPosition" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundPosition *woundPosition = [array lastObject];
    if (create && nil == woundPosition) {
        woundPosition = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundPosition.title = title;
    }
    return woundPosition;
}

+ (WMWoundPosition *)woundPositionForCommonTitle:(NSString *)commonTitle
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPosition" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"commonTitle == %@", commonTitle]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundPosition *woundPosition = [array lastObject];
    if (create && nil == woundPosition) {
        woundPosition = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundPosition.commonTitle = commonTitle;
    }
    return woundPosition;
}

@end

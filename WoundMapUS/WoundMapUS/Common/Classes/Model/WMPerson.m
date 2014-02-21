#import "WMPerson.h"
#import "StackMob.h"

@interface WMPerson ()

// Private interface goes here.

@end


@implementation WMPerson

@dynamic managedObjectContext, objectID;

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMPerson *person = [[WMPerson alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPerson" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:person toPersistentStore:store];
	}
    [person setValue:[person assignObjectId] forKey:[person primaryKeyField]];
	return person;
}

- (NSString *)lastNameFirstName
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if ([self.nameFamily length] > 0) {
        [array addObject:self.nameFamily];
    }
    if ([self.nameGiven length] > 0) {
        [array addObject:self.nameGiven];
    }
    if ([array count] == 0) {
        [array addObject:@"New Patient"];
    }
    return [array componentsJoinedByString:@", "];
}

@end

#import "WMCarePlanValue.h"
#import "WMCarePlanCategory.h"

@interface WMCarePlanValue ()

// Private interface goes here.

@end


@implementation WMCarePlanValue

- (NSArray *)categoryPathToValue
{
    NSMutableArray *path = [[NSMutableArray alloc] initWithCapacity:16];
    WMCarePlanCategory *category = nil;
    NSString *string = nil;
    if (nil != self.category) {
        string = self.category.title;
        if (nil != self.category.snomedCID) {
            string = [string stringByAppendingFormat:@" (%@)", self.category.snomedCID];
        }
        [path addObject:string];
        category = self.category.parent;
    }
    while (nil != category) {
        string = category.title;
        if (nil != category.snomedCID) {
            string = [string stringByAppendingFormat:@" (%@)", category.snomedCID];
        }
        if (nil != self.value) {
            string = [string stringByAppendingFormat:@": (%@)", self.value];
        }
        [path insertObject:string atIndex:0];
        category = category.parent;
    }
    return path;
}

- (NSString *)pathToValue
{
    return [self.categoryPathToValue componentsJoinedByString:@","];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMCarePlanValue *carePlanValue = [[WMCarePlanValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMCarePlanValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:carePlanValue toPersistentStore:store];
	}
	return carePlanValue;
}

@end

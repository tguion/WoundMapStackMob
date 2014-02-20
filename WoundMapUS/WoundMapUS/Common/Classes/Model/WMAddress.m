#import "WMAddress.h"
#import "StackMob.h"

@interface WMAddress ()

// Private interface goes here.

@end


@implementation WMAddress

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMAddress *address = [[WMAddress alloc] initWithEntity:[NSEntityDescription entityForName:@"WMAddress" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:address toPersistentStore:store];
	}
    [address setValue:[address assignObjectId] forKey:[address primaryKeyField]];
	return address;
}

- (NSString *)stringValue
{
    NSMutableArray *array0 = [NSMutableArray arrayWithCapacity:4];
    if ([self.streetAddressLine length] > 0) {
        [array0 addObject:self.streetAddressLine];
    }
    if ([self.streetAddressLine1 length] > 0) {
        [array0 addObject:self.streetAddressLine1];
    }
    NSMutableArray *array1 = [NSMutableArray arrayWithCapacity:4];
    if ([self.city length] > 0) {
        [array1 addObject:[NSString stringWithFormat:@"%@,", self.city]];
    }
    if ([self.state length] > 0) {
        [array1 addObject:self.state];
    }
    if ([self.postalCode length] > 0) {
        [array1 addObject:self.postalCode];
    }
    if ([self.country length] > 0) {
        [array1 addObject:self.country];
    }
    [array0 addObject:[array1 componentsJoinedByString:@" "]];
    if ([array0 count] == 0) {
        [array0 addObject:@"New Address"];
    }
    return [array0 componentsJoinedByString:@"\n"];
}

@end

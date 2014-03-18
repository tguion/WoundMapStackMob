#import "WMPerson.h"

@interface WMPerson ()

// Private interface goes here.

@end


@implementation WMPerson

@dynamic managedObjectContext, objectID;

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

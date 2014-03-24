#import "WMPerson.h"

@interface WMPerson ()

// Private interface goes here.

@end


@implementation WMPerson

@dynamic managedObjectContext, objectID;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
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

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"lastNameFirstName"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"objectID"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"managedObjectContext"]) {
        return NO;
    }
    
    // else
    return YES;
}

@end

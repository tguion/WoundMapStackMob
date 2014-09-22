#import "WMAddress.h"
#import "WMPerson.h"
#import "WMOrganization.h"

@interface WMAddress ()

// Private interface goes here.

@end


@implementation WMAddress

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
    return [array0 componentsJoinedByString:@"\r"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return (self.person ? self.person:self.organization);
}

- (BOOL)requireUpdatesFromCloud
{
    return YES;
}

#pragma mar - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"stringValue",
                                                            @"stringValue",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator",
                                                            @"objectID"]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMAddress attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

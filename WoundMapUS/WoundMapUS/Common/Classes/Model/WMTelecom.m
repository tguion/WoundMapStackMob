#import "WMTelecom.h"
#import "WMTelecomType.h"

@interface WMTelecom ()

// Private interface goes here.

@end


@implementation WMTelecom

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)isEmail
{
    return self.telecomType.isEmail;
}

- (NSString *)stringValue
{
    NSMutableArray *array0 = [NSMutableArray arrayWithCapacity:4];
    if ([self.use length] > 0) {
        [array0 addObject:self.use];
    }
    if (self.telecomType) {
        [array0 addObject:self.telecomType.title];
    }
    if ([self.value length] > 0) {
        [array0 addObject:self.value];
    }
    return [array0 componentsJoinedByString:@":"];
}

#pragma mar - FatFractal

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"isEmail"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"stringValue"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"objectID"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"flagsValue"]) {
        return NO;
    }
    // else
    return YES;
}

@end

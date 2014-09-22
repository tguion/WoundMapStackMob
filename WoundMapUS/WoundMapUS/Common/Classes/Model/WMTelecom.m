#import "WMTelecom.h"
#import "WMTelecomType.h"
#import "WMPerson.h"

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

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return self.person;
}

- (BOOL)requireUpdatesFromCloud
{
    return YES;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"isEmail",
                                                            @"stringValue",
                                                            @"objectID",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMTelecom attributeNamesNotToSerialize] containsObject:propertyName] || [[WMTelecom relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMTelecom relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

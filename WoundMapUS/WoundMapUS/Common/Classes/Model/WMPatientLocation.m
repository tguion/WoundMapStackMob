#import "WMPatientLocation.h"
#import "WMPatient.h"

@interface WMPatientLocation ()

// Private interface goes here.

@end


@implementation WMPatientLocation

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return self.patient;
}

- (BOOL)requireUpdatesFromCloud
{
    return YES;
}

- (NSString *)locationForDisplay
{
    NSMutableArray *array = [NSMutableArray array];
    if (self.facility) {
        [array addObject:self.facility];
    }
    if (self.unit) {
        [array addObject:self.unit];
    }
    if (self.room) {
        [array addObject:self.room];
    }
    if (self.location) {
        [array addObject:self.location];
    }
    return [array componentsJoinedByString:@","];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue", @"aggregator", @"requireUpdatesFromCloud", @"locationForDisplay"]];
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
    if ([[WMPatientLocation attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPatientLocation relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPatientLocation relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

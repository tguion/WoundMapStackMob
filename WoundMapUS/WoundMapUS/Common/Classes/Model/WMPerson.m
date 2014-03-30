#import "WMPerson.h"
#import "WMTelecom.h"
#import "WMTelecomType.h"

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

- (WMTelecom *)defaultEmailTelecom
{
    return [WMTelecom MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"telecomType.title == %@", kTelecomTypeEmailTitle]
                                       sortedBy:WMTelecomAttributes.createdAt
                                      ascending:YES
                                      inContext:[self managedObjectContext]];
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"flagsValue",
                                        @"lastNameFirstName",
                                        @"defaultEmailTelecom"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMPersonRelationships.addresses,
                                        WMPersonRelationships.telecoms];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPerson attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPerson relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

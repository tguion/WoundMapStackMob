#import "WMPerson.h"
#import "WMTelecom.h"
#import "WMTelecomType.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"

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

#pragma mark - AddressSource

- (NSSet *)addressesWithRefreshHandler:(dispatch_block_t)handler
{
    WM_ASSERT_MAIN_THREAD;
    // update from back end
    if (self.ffUrl) {
        [[WMFatFractal sharedInstance] grabBagGetAllForObj:self
                                               grabBagName:WMPersonRelationships.addresses
                                                onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                    WM_ASSERT_MAIN_THREAD;
                                                    handler();
                                                }];
    } else {
        handler();
    }
    return self.addresses;
}

#pragma mark - TelecomSource

- (NSSet *)telecomsWithRefreshHandler:(dispatch_block_t)handler
{
    WM_ASSERT_MAIN_THREAD;
    // update from back end
    if (self.ffUrl) {
        [[WMFatFractal sharedInstance] grabBagGetAllForObj:self
                                               grabBagName:WMPersonRelationships.telecoms
                                                onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                    WM_ASSERT_MAIN_THREAD;
                                                    handler();
                                                }];
    } else {
        handler();
    }
    return self.telecoms;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"lastNameFirstName",
                                                            @"defaultEmailTelecom",
                                                            @"managedObjectContext",
                                                            @"objectID"]];
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
    if ([[WMPerson attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPerson relationshipNamesNotToSerialize] containsObject:propertyName]) {
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

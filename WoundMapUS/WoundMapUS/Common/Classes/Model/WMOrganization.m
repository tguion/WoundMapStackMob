#import "WMOrganization.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@interface WMOrganization ()

// Private interface goes here.

@end


@implementation WMOrganization

@dynamic managedObjectContext, objectID;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

#pragma mark - AddressSource

- (NSSet *)addressesWithRefreshHandler:(dispatch_block_t)handler
{
    WM_ASSERT_MAIN_THREAD;
    // update from back end
    if (self.ffUrl) {
        [[WMFatFractal sharedInstance] grabBagGetAllForObj:self
                                               grabBagName:WMOrganizationRelationships.addresses
                                                onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                                    if (error) {
                                                        [WMUtilities logError:error];
                                                    }
                                                    handler();
                                                }];
    } else {
        handler();
    }
    return self.addresses;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
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
    if ([[WMOrganization attributeNamesNotToSerialize] containsObject:propertyName] || [[WMOrganization relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMOrganization relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

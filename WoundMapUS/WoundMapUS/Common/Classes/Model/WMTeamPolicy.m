#import "WMTeamPolicy.h"
#import "WMTeam.h"
#import "WMFatFractal.h"

@interface WMTeamPolicy ()

// Private interface goes here.

@end


@implementation WMTeamPolicy

+ (WMTeamPolicy *)teamPolicyForTeam:(WMTeam *)team
{
    WMTeamPolicy *teamPolicy = team.teamPolicy;
    if (nil == teamPolicy) {
        teamPolicy = [WMTeamPolicy MR_createInContext:[team managedObjectContext]];
        teamPolicy.team = team;
    }
    return teamPolicy;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"deletePhotoBlobsValue",
                                                            @"flagsValue",
                                                            @"numberOfMonthsToDeletePhotoBlobsValue"]];
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
    if ([[WMTeamPolicy attributeNamesNotToSerialize] containsObject:propertyName] || [[WMTeamPolicy relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMTeamPolicy relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

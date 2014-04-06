#import "WMTeam.h"
#import "WMParticipant.h"
#import "WMFatFractal.h"

NSString * const kParticipantGroupName = @"participantGroup";

@interface WMTeam ()

// Private interface goes here.

@end


@implementation WMTeam

@synthesize participantGroup=_participantGroup;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (FFUserGroup *)participantGroup
{
    if (_participantGroup == nil) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        _participantGroup = [[FFUserGroup alloc] initWithFF:ff];
        [_participantGroup setGroupName:kParticipantGroupName];
    }
    return _participantGroup;
}

- (WMParticipant *)teamLeader
{
    return [[[self.participants allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isTeamLeader == YES"]] lastObject];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"teamLeader"]];
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
    if ([[WMTeam attributeNamesNotToSerialize] containsObject:propertyName] || [[WMTeam relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMTeam relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

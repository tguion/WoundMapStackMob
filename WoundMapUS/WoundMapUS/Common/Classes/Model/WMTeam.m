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

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
//        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMTeamRelationships.invitations,
//                                                            WMTeamRelationships.navigationTracks,
//                                                            WMTeamRelationships.participants,
//                                                            WMTeamRelationships.patients]];
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

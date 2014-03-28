#import "WMTeam.h"
#import "WMParticipant.h"
#import "WCAppDelegate.h"

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
        [_participantGroup setGroupName:@"participantGroup"];
    }
    return _participantGroup;
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"flagsValue"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMTeamRelationships.invitations,
                                        WMTeamRelationships.navigationTracks,
                                        WMTeamRelationships.participants,
                                        WMTeamRelationships.patients];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMTeam attributeNamesNotToSerialize] containsObject:propertyName]) {
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

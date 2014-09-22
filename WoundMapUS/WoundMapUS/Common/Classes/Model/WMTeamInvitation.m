#import "WMTeamInvitation.h"
#import "WMParticipant.h"

@interface WMTeamInvitation ()

// Private interface goes here.

@end


@implementation WMTeamInvitation

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMTeamInvitation *)createInvitationForParticipant:(WMParticipant *)participant passcode:(NSInteger)passcode
{
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    WMTeamInvitation *teamInvitation = [WMTeamInvitation MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"invitee == %@", participant] inContext:managedObjectContext];
    if (nil == teamInvitation) {
        teamInvitation = [WMTeamInvitation MR_createInContext:managedObjectContext];
        teamInvitation.invitee = participant;
        teamInvitation.passcode = @(passcode);
    }
    return teamInvitation;
}

- (BOOL)isAccepted
{
    return self.acceptedFlagValue;
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return nil;
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"acceptedFlagValue",
                                                            @"confirmedFlagValue",
                                                            @"addedToTeamFlagValue",
                                                            @"flagsValue",
                                                            @"passcodeValue",
                                                            @"isAccepted",
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
    if ([[WMTeamInvitation attributeNamesNotToSerialize] containsObject:propertyName] || [[WMTeamInvitation relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMTeamInvitation relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

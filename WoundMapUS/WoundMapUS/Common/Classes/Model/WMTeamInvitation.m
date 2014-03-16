#import "WMTeamInvitation.h"
#import "WMParticipant.h"

@interface WMTeamInvitation ()

// Private interface goes here.

@end


@implementation WMTeamInvitation

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

@end

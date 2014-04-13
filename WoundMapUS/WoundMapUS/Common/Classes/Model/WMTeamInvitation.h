#import "_WMTeamInvitation.h"

@interface WMTeamInvitation : _WMTeamInvitation {}

@property (strong, nonatomic) FFUser *user; // invitee's user
@property (nonatomic, readonly) BOOL isAccepted;

+ (WMTeamInvitation *)createInvitationForParticipant:(WMParticipant *)participant passcode:(NSInteger)passcode;

@end

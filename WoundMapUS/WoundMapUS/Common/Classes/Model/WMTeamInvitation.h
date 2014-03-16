#import "_WMTeamInvitation.h"

@interface WMTeamInvitation : _WMTeamInvitation {}

@property (nonatomic, readonly) BOOL isAccepted;

+ (WMTeamInvitation *)createInvitationForParticipant:(WMParticipant *)participant passcode:(NSInteger)passcode;

@end

#import "_WMTeamInvitation.h"
#import "WMFFManagedObject.h"

@interface WMTeamInvitation : _WMTeamInvitation <WMFFManagedObject> {}

@property (nonatomic, readonly) BOOL isAccepted;

+ (WMTeamInvitation *)createInvitationForParticipant:(WMParticipant *)participant passcode:(NSInteger)passcode;

@end

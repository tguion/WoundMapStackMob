#import "_WMTeam.h"

@interface WMTeam : _WMTeam {}

@property (strong, nonatomic) FFUserGroup *participantGroup;

- (void)addParticipantsToParticipantGroup;

@end

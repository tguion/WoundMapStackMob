#import "_WMTeam.h"
#import <FFEF/FatFractal.h>

@interface WMTeam : _WMTeam {}

@property (strong, nonatomic) FFUserGroup *participantGroup;

- (void)addParticipantsToParticipantGroup;

@end

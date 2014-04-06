#import "_WMTeam.h"

extern NSString * const kParticipantGroupName;

@interface WMTeam : _WMTeam {}

+ (NSSet *)relationshipNamesNotToSerialize;

@property (strong, nonatomic) FFUserGroup *participantGroup;
@property (readonly, nonatomic) WMParticipant *teamLeader;

@end

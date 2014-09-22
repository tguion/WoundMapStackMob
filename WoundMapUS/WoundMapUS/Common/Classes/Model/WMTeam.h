#import "_WMTeam.h"
#import "WMFFManagedObject.h"

extern NSString * const kParticipantGroupName;

@interface WMTeam : _WMTeam <WMFFManagedObject> {}

+ (NSSet *)relationshipNamesNotToSerialize;

@property (strong, nonatomic) FFUserGroup *participantGroup;
@property (readonly, nonatomic) WMParticipant *teamLeader;

@end

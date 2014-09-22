#import "_WMTeamPolicy.h"
#import "WMFFManagedObject.h"

@interface WMTeamPolicy : _WMTeamPolicy <WMFFManagedObject> {}

+ (WMTeamPolicy *)teamPolicyForTeam:(WMTeam *)team;

@end

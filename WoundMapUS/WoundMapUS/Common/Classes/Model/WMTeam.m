#import "WMTeam.h"
#import "WMParticipant.h"
#import "WCAppDelegate.h"

@interface WMTeam ()

// Private interface goes here.

@end


@implementation WMTeam

@synthesize participantGroup=_participantGroup;

- (void)addParticipantsToParticipantGroup
{
    NSParameterAssert(nil != _participantGroup);
    NSError *error = nil;
    NSArray *current = [_participantGroup getUsersWithError:&error];
    for (WMParticipant *participant in self.participants) {
        if ([current containsObject:participant]) {
            continue;
        }
        // else
        [_participantGroup addUser:participant error:&error];
    }
}

@end

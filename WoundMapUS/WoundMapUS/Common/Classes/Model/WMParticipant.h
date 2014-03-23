#import "_WMParticipant.h"

@interface WMParticipant : _WMParticipant <FFUserProtocol> {}

+ (NSInteger)participantCount:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)bestMatchingParticipantForUserName:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)participantForName:(NSString *)name
                               create:(BOOL)create
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)participantForUserName:(NSString *)userName
                                   create:(BOOL)create
                     managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (nonatomic) BOOL isTeamLeader;

@end

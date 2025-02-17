#import "_WMParticipant.h"
#import "WMFFManagedObject.h"

@interface WMParticipant : _WMParticipant <WMFFManagedObject> {}

+ (NSSet *)relationshipNamesNotToSerialize;

+ (NSInteger)participantCount:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)bestMatchingParticipantForUserName:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)participantForName:(NSString *)name
                               create:(BOOL)create
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMParticipant *)participantForUserName:(NSString *)userName
                                   create:(BOOL)create
                     managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (strong, nonatomic) FFUser *user;

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;

@property (readonly, nonatomic) NSString *lastNameFirstName;
@property (nonatomic) BOOL teamLeaderIAPPurchaseSuccessful;
@property (nonatomic) BOOL isTeamLeader;
@property (nonatomic) BOOL teamAddedIAPPurchaseSuccessful;
@property (readonly, nonatomic) BOOL isIntroductoryTeamPricing;

- (NSInteger)addReportTokens:(NSInteger)tokens;

- (NSArray *)targetPatientReferrals:(BOOL)showOnlyOpenReferrals;

@end

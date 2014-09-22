#import "WMParticipant.h"
#import "WMParticipantType.h"
#import "WMPerson.h"
#import "WMTeamInvitation.h"
#import "WMPatientReferral.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

#define kNumberOfMonthsIntroductoryPrice 3

typedef NS_ENUM(int16_t, WMParticipantFlags) {
    ParticipantFlagsTeamLeader  = 0,
    ParticipantFlagsTeamLeaderIAPSuccess  = 1,
    ParticipantFlagsTeamAddedIAPSuccess  = 2,
};

@interface WMParticipant ()

// Private interface goes here.

@end


@implementation WMParticipant

@synthesize user=_user;
@dynamic firstName, lastName;
@dynamic teamLeaderIAPPurchaseSuccessful, teamAddedIAPPurchaseSuccessful;

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMParticipant *participant = [[WMParticipant alloc] initWithEntity:[NSEntityDescription entityForName:@"WMParticipant" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:participant toPersistentStore:store];
	}
	return participant;
}

+ (NSInteger)participantCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMParticipant MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (WMParticipant *)bestMatchingParticipantForUserName:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMParticipant MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", name] inContext:managedObjectContext];
}

+ (WMParticipant *)participantForName:(NSString *)name
                               create:(BOOL)create
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMParticipant *participant = [WMParticipant MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]
                                                                inContext:managedObjectContext];
    if (create && nil == participant) {
        participant = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        participant.name = name;
    }
    return participant;
}

+ (WMParticipant *)participantForUserName:(NSString *)userName
                                   create:(BOOL)create
                     managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMParticipant *participant = [WMParticipant MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userName == %@", userName]
                                                                inContext:managedObjectContext];
    if (create && nil == participant) {
        participant = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        participant.userName = userName;
    }
    return participant;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    self.reportTokenCount = @(20);
}

- (NSString *)firstName
{
    return self.person.nameGiven;
}

- (void)setFirstName:(NSString *)firstName
{
    self.person.nameGiven =firstName;
}

- (NSString *)lastName
{
    return self.person.nameFamily;
}

- (void)setLastName:(NSString *)lastName
{
    self.person.nameFamily = lastName;
}

- (NSString *)lastNameFirstName
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if ([self.person.nameFamily length] > 0) {
        [array addObject:self.person.nameFamily];
    }
    if ([self.person.nameGiven length] > 0) {
        [array addObject:self.person.nameGiven];
    }
    if ([array count] == 0) {
        [array addObject:@"New Person"];
    }
    return [array componentsJoinedByString:@", "];
}

- (BOOL)teamLeaderIAPPurchaseSuccessful
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:ParticipantFlagsTeamLeaderIAPSuccess];
}

- (void)setTeamLeaderIAPPurchaseSuccessful:(BOOL)teamLeaderIAPPurchaseSuccessful
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:ParticipantFlagsTeamLeaderIAPSuccess to:teamLeaderIAPPurchaseSuccessful]);
}

- (BOOL)teamAddedIAPPurchaseSuccessful
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:ParticipantFlagsTeamAddedIAPSuccess];
}

- (void)setTeamAddedIAPPurchaseSuccessful:(BOOL)teamAddedIAPPurchaseSuccessful
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:ParticipantFlagsTeamAddedIAPSuccess to:teamAddedIAPPurchaseSuccessful]);
}

- (BOOL)isTeamLeader
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:ParticipantFlagsTeamLeader];
}

- (void)setIsTeamLeader:(BOOL)isTeamLeader
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:ParticipantFlagsTeamLeader to:isTeamLeader]);
}

- (BOOL)isIntroductoryTeamPricing
{
    NSDate *threeMonths = [WMUtilities dateByAddingMonths:kNumberOfMonthsIntroductoryPrice toDate:self.dateAddedToTeam];
    NSDate *now = [NSDate date];
    return [threeMonths compare:now] == NSOrderedAscending;
}

- (NSInteger)addReportTokens:(NSInteger)tokens
{
    self.reportTokenCountValue = (self.reportTokenCountValue + tokens);
    self.lastTokenCreditPurchaseDate = [NSDate date];
    return self.reportTokenCountValue;
}

- (NSArray *)targetPatientReferrals:(BOOL)showOnlyOpenReferrals
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *predicate = nil;
    if (showOnlyOpenReferrals) {
        predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K = nil", WMPatientReferralRelationships.referree, self, WMPatientReferralAttributes.dateAccepted];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"%K == %@", WMPatientReferralRelationships.referree, self];
    }
    return [WMPatientReferral MR_findAllSortedBy:WMPatientReferralAttributes.createdAt ascending:NO withPredicate:predicate inContext:managedObjectContext];
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return nil;
}

- (BOOL)requireUpdatesFromCloud
{
    return NO;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"permissionsValue",
                                                            @"reportTokenCountValue",
                                                            @"firstName",
                                                            @"lastName",
                                                            @"lastNameFirstName",
                                                            @"isTeamLeader",
                                                            @"teamLeaderIAPPurchaseSuccessful",
                                                            @"teamAddedIAPPurchaseSuccessful",
                                                            @"isIntroductoryTeamPricing",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMParticipant attributeNamesNotToSerialize] containsObject:propertyName] || [[WMParticipant relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMParticipant relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}


@end

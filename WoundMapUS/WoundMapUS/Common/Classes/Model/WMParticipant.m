#import "WMParticipant.h"
#import "WMParticipantType.h"
#import "WMPerson.h"
#import "WMUtilities.h"

@interface WMParticipant ()

// Private interface goes here.

@end


@implementation WMParticipant

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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
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

@end

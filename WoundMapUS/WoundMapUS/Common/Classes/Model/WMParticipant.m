#import "WMParticipant.h"
#import "WMParticipantType.h"
#import "WMUtilities.h"
#import "StackMob.h"

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
    [participant setValue:[participant assignObjectId] forKey:[participant primaryKeyField]];
	return participant;
}

+ (NSInteger)participantCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMParticipant" inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (WMParticipant *)bestMatchingParticipantForUserName:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMParticipant" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", name]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return [array lastObject];
}

+ (WMParticipant *)participantForName:(NSString *)name
                               create:(BOOL)create
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                      persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMParticipant" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMParticipant *participant = [array lastObject];
    if (create && nil == participant) {
        participant = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        participant.name = name;
    }
    return participant;
}

+ (WMParticipant *)duplicateParticipant:(WMParticipant *)participant
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store
{
    WMParticipant *duplicatedParticipant = [self participantForName:participant.name create:NO managedObjectContext:managedObjectContext persistentStore:store];
    if (nil == duplicatedParticipant) {
        duplicatedParticipant = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        duplicatedParticipant.name = participant.name;
    }
    duplicatedParticipant.dateCreated = participant.dateCreated;
    duplicatedParticipant.dateLastSignin = participant.dateLastSignin;
    duplicatedParticipant.email = participant.email;
    duplicatedParticipant.flags = participant.flags;
    duplicatedParticipant.permissions = participant.permissions;
    WMParticipantType *participantType = participant.participantType;
    if (nil != participantType) {
        duplicatedParticipant.participantType = [WMParticipantType participantTypeForTitle:participantType.title
                                                                                    create:NO
                                                                      managedObjectContext:managedObjectContext
                                                                           persistentStore:store];
    }
    return duplicatedParticipant;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
}

@end

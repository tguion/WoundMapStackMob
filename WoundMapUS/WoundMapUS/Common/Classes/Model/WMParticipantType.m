#import "WMParticipantType.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMParticipantType ()

// Private interface goes here.

@end


@implementation WMParticipantType

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMParticipantType *participantType = [[WMParticipantType alloc] initWithEntity:[NSEntityDescription entityForName:@"WMParticipantType" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:participantType toPersistentStore:store];
	}
    [participantType setValue:[participantType assignObjectId] forKey:[participantType primaryKeyField]];
	return participantType;
}

+ (NSInteger)participantTypeCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    __block NSInteger count = 0;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"WMParticipantType" inManagedObjectContext:managedObjectContext]];
        count = [managedObjectContext countForFetchRequest:request error:NULL];
    }];
    return count;
}

+ (WMParticipantType *)participantTypeForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMParticipantType" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMParticipantType *participantType = [array lastObject];
    if (create && nil == participantType) {
        participantType = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        participantType.title = title;
    }
    return participantType;
}

+ (NSArray *)sortedParticipantTypes:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMParticipantType" inManagedObjectContext:managedObjectContext]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return array;
}

+ (WMParticipantType *)updateParticipantTypeFromDictionary:(NSDictionary *)dictionary
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                           persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMParticipantType *participantType = [self participantTypeForTitle:title
                                                                create:YES
                                                  managedObjectContext:managedObjectContext
                                                       persistentStore:store];
    participantType.sortRank = [dictionary objectForKey:@"sortRank"];
    participantType.definition = [dictionary objectForKey:@"definition"];
    participantType.loincCode = [dictionary objectForKey:@"LOINC Code"];
    participantType.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    participantType.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    return participantType;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"RoleType" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"RoleType.plist file not found");
		return;
	}
    // else check count
    if ([WMParticipantType participantTypeCount:managedObjectContext persistentStore:store] > 0) {
        return;
    }
    // else
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an array, class was %@", NSStringFromClass([propertyList class]));
        for (NSDictionary *dictionary in propertyList) {
            [self updateParticipantTypeFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

@end

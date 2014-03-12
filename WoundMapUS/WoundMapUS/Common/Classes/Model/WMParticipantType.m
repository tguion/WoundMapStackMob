#import "WMParticipantType.h"
#import "WMUtilities.h"

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
	return participantType;
}

+ (NSInteger)participantTypeCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMParticipantType MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (WMParticipantType *)participantTypeForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMParticipantType *participantType = [WMParticipantType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == participantType) {
        participantType = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        participantType.title = title;
    }
    return participantType;
}

+ (NSArray *)sortedParticipantTypes:(NSManagedObjectContext *)managedObjectContext
{
    return [WMParticipantType MR_findAllSortedBy:@"sortRank" ascending:YES inContext:managedObjectContext];
}

+ (WMParticipantType *)updateParticipantTypeFromDictionary:(NSDictionary *)dictionary
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMParticipantType *participantType = [self participantTypeForTitle:title
                                                                create:YES
                                                  managedObjectContext:managedObjectContext];
    participantType.sortRank = [dictionary objectForKey:@"sortRank"];
    participantType.definition = [dictionary objectForKey:@"definition"];
    participantType.loincCode = [dictionary objectForKey:@"LOINC Code"];
    participantType.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    participantType.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    return participantType;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"RoleType" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"RoleType.plist file not found");
		return;
	}
    // else check count
    if ([WMParticipantType participantTypeCount:managedObjectContext] > 0) {
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
            [self updateParticipantTypeFromDictionary:dictionary managedObjectContext:managedObjectContext];
        }
    }
}

@end

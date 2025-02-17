#import "WMParticipantType.h"
#import "WMUtilities.h"

@interface WMParticipantType ()

// Private interface goes here.

@end


@implementation WMParticipantType

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
        participantType = [WMParticipantType MR_createInContext:managedObjectContext];
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

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
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
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMParticipantType *participantType = [self updateParticipantTypeFromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[participantType objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[participantType objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMParticipantType entityName], nil);
        }
    }
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
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
                                                            @"snomedCIDValue",
                                                            @"sortRankValue",
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMParticipantTypeRelationships.participants]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMParticipantType attributeNamesNotToSerialize] containsObject:propertyName] || [[WMParticipantType relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMParticipantType relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}


@end

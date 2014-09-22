#import "WMMedicalHistoryItem.h"
#import "WMUtilities.h"

@interface WMMedicalHistoryItem ()

// Private interface goes here.

@end


@implementation WMMedicalHistoryItem

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (NSArray *)sortedMedicalHistoryItems:(NSManagedObjectContext *)managedObjectContext
{
    return [WMMedicalHistoryItem MR_findAllSortedBy:WMMedicalHistoryItemAttributes.sortRank ascending:YES inContext:managedObjectContext];
}

+ (WMMedicalHistoryItem *)medicalHistoryItemForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMMedicalHistoryItem *medicalHistoryItem = [WMMedicalHistoryItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == medicalHistoryItem) {
        medicalHistoryItem = [WMMedicalHistoryItem MR_createInContext:managedObjectContext];
        medicalHistoryItem.title = title;
    }
    return medicalHistoryItem;
}

+ (WMMedicalHistoryItem *)updateMedicalHistoryItemFromDictionary:(NSDictionary *)dictionary
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMMedicalHistoryItem *medicalHistoryItem = [self medicalHistoryItemForTitle:title
                                                                         create:YES
                                                           managedObjectContext:managedObjectContext];
    medicalHistoryItem.definition = [dictionary objectForKey:@"definition"];
    medicalHistoryItem.loincCode = [dictionary objectForKey:@"LOINC Code"];
    medicalHistoryItem.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    medicalHistoryItem.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    medicalHistoryItem.sortRank = [dictionary objectForKey:@"sortRank"];
    medicalHistoryItem.valueTypeCode = [dictionary objectForKey:@"valueTypeCode"];
    return medicalHistoryItem;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"MedicalHistory" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"MedicalHistory.plist file not found");
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
            WMMedicalHistoryItem *medicalHistoryItem = [self updateMedicalHistoryItemFromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[medicalHistoryItem objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[medicalHistoryItem objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMMedicalHistoryItem entityName], nil);
        }
    }
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
                                                            @"valueTypeCodeValue",
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMMedicalHistoryItemRelationships.values]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMMedicalHistoryItem attributeNamesNotToSerialize] containsObject:propertyName] || [[WMMedicalHistoryItem relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMMedicalHistoryItem relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}


@end

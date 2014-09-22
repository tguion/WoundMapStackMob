#import "WMWoundOdor.h"
#import "WMUtilities.h"

@interface WMWoundOdor ()

// Private interface goes here.

@end


@implementation WMWoundOdor

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMWoundOdor *)woundOdorForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundOdor *woundOdor = [WMWoundOdor MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == woundOdor) {
        woundOdor = [WMWoundOdor MR_createInContext:managedObjectContext];
        woundOdor.title = title;
    }
    return woundOdor;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundOdor" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WoundOdor.plist file not found");
		return;
	}
    // else count
    if ([WMWoundOdor MR_countOfEntitiesWithContext:managedObjectContext] > 0) {
        return;
    }
    // else load
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an NSArray, class was %@", NSStringFromClass([propertyList class]));
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMWoundOdor *woundOdor = [self updateWoundOdorFromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[woundOdor objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[woundOdor objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMWoundOdor entityName], nil);
        }
    }
}

+ (WMWoundOdor *)updateWoundOdorFromDictionary:(NSDictionary *)dictionary
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundOdor *woundOdor = [WMWoundOdor woundOdorForTitle:title
                                                     create:YES
                                       managedObjectContext:managedObjectContext];
    woundOdor.definition = [dictionary objectForKey:@"definition"];
    woundOdor.label = [dictionary objectForKey:@"label"];
    woundOdor.placeHolder = [dictionary objectForKey:@"placeHolder"];
    woundOdor.valueTypeCode = [dictionary objectForKey:@"valueTypeCode"];
    woundOdor.sectionTitle = [dictionary objectForKey:@"sectionTitle"];
    woundOdor.sortRank = [dictionary objectForKey:@"sortRank"];
    woundOdor.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    woundOdor.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    woundOdor.loincCode = [dictionary objectForKey:@"LOINC Code"];
    return woundOdor;
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMWoundOdorRelationships.measurementValues]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundOdor attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundOdor relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundOdor relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

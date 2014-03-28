#import "WMAmountQualifier.h"
#import "WMUtilities.h"

@interface WMAmountQualifier ()

// Private interface goes here.

@end


@implementation WMAmountQualifier

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMAmountQualifier *)amountQualifierForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMAmountQualifier *amountQualifier = [WMAmountQualifier MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == amountQualifier) {
        amountQualifier = [WMAmountQualifier MR_createInContext:managedObjectContext];
        amountQualifier.title = title;
    }
    return amountQualifier;
}

+ (WMAmountQualifier *)updateAmountQualifierFromDictionary:(NSDictionary *)dictionary
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMAmountQualifier *amountQualifier = [self amountQualifierForTitle:title
                                                                create:YES
                                                  managedObjectContext:managedObjectContext];
    amountQualifier.loincCode = [dictionary objectForKey:@"LOINC Code"];
    amountQualifier.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    amountQualifier.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    amountQualifier.sortRank = [dictionary objectForKey:@"sortRank"];
    return amountQualifier;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"AmountQualifier" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"AmountQualifier.plist file not found");
		return;
	}
    // else count
    if ([WMAmountQualifier MR_countOfEntitiesWithContext:managedObjectContext] > 0) {
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
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an array, class was %@", NSStringFromClass([propertyList class]));
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMAmountQualifier *amountQualifier = [self updateAmountQualifierFromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[amountQualifier objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[amountQualifier objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMAmountQualifier entityName]);
        }
    }
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"flagsValue",
                                        @"snomedCIDValue",
                                        @"sortRankValue",
                                        @"valueTypeCodeValue"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMAmountQualifierRelationships.measurementValues];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMAmountQualifier attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMAmountQualifier relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

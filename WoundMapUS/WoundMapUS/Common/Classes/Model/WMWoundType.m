#import "WMWoundType.h"
#import "WMUtilities.h"

NSString * const kOtherWoundTypeTitle = @"Other";

@interface WMWoundType ()

// Private interface goes here.

@end


@implementation WMWoundType

- (BOOL)isOther
{
    return [kOtherWoundTypeTitle isEqualToString:self.title];
}

- (BOOL)hasChildrenWoundTypes
{
    return [self.children count] > 0;
}

- (BOOL)childrenHaveSectionTitles
{
    if (!self.hasChildrenWoundTypes) {
        return NO;
    }
    // else
    for (WMWoundType *woundType in self.children) {
        if ([woundType.sectionTitle length] > 0) {
            return YES;
        }
    }
    // else
    return NO;
}

- (NSString *)titleForDisplay
{
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:4];
    WMWoundType *woundType = self;
    while (nil != woundType) {
        [titles insertObject:woundType.title atIndex:0];
        woundType = woundType.parent;
    }
    return [titles componentsJoinedByString:@","];
}

+ (NSInteger)woundTypeCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundType MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundType" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WoundType.plist file not found");
		return;
	}
    // else see if seeded
    NSInteger count = [self woundTypeCount:managedObjectContext];
    if (count > 0 && count != NSNotFound) {
        return;
    }
    // else
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        NSError *error = nil;
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an NSArray, class was %@", NSStringFromClass([propertyList class]));
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMWoundType *woundType = [self updateWoundTypeFromDictionary:dictionary managedObjectContext:managedObjectContext objectIDs:objectIDs];
            NSAssert(![[woundType objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[woundType objectID]];
        }
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMWoundType entityName]);
        }
    }
}

+ (WMWoundType *)updateWoundTypeFromDictionary:(NSDictionary *)dictionary
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     objectIDs:(NSMutableArray *)objectIDs
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundType *woundType = [WMWoundType woundTypeForTitle:title
                                                     create:YES
                                       managedObjectContext:managedObjectContext];
    woundType.definition = [dictionary objectForKey:@"definition"];
    woundType.label = [dictionary objectForKey:@"label"];
    woundType.options = [dictionary objectForKey:@"options"];
    woundType.placeHolder = [dictionary objectForKey:@"placeHolder"];
    woundType.valueTypeCode = [dictionary objectForKey:@"valueTypeCode"];
    woundType.woundTypeCode = [dictionary objectForKey:@"woundTypeCode"];
    woundType.sectionTitle = [dictionary objectForKey:@"sectionTitle"];
    woundType.sortRank = [dictionary objectForKey:@"sortRank"];
    woundType.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    woundType.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    woundType.loincCode = [dictionary objectForKey:@"LOINC Code"];
    id children = [dictionary objectForKey:@"children"];
    if ([children isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in children) {
            WMWoundType *woundType = [self updateWoundTypeFromDictionary:d managedObjectContext:managedObjectContext objectIDs:objectIDs];
            [woundType addChildrenObject:woundType];
            NSAssert(![[woundType objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[woundType objectID]];
        }
    }
    NSAssert(![[woundType objectID] isTemporaryID], @"Expect a permanent objectID");
    [objectIDs addObject:[woundType objectID]];
    return woundType;
}

+ (WMWoundType *)woundTypeForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundType *woundType = [WMWoundType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == woundType) {
        woundType = [WMWoundType MR_createInContext:managedObjectContext];
        woundType.title = title;
    }
    return woundType;
}

+ (NSArray *)woundTypesForWoundTypeCode:(NSInteger)woundTypeCodeValue
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundType MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"woundTypeCode == %d", woundTypeCodeValue] inContext:managedObjectContext];
}

+ (WMWoundType *)otherWoundType:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", kOtherWoundTypeTitle] inContext:managedObjectContext];
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return [self.valueTypeCode intValue];
}

- (NSString *)unit
{
    return nil;
}

- (void)setUnit:(NSString *)unit
{
}

- (id)value
{
    return nil;
}

- (void)setValue:(id)value
{
}

- (NSArray *)optionsArray
{
    return [NSArray array];
}

- (NSArray *)secondaryOptionsArray
{
    return self.optionsArray;
}

- (NSSet *)interventionEvents
{
    return [NSSet set];
}

- (void)setInterventionEvents:(NSSet *)interventionEvents
{
    
}

@end

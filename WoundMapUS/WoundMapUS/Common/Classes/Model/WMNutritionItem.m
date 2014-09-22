#import "WMNutritionItem.h"
#import "WMUtilities.h"

@interface WMNutritionItem ()

// Private interface goes here.

@end


@implementation WMNutritionItem

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMNutritionItem *)nutritionItemForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMNutritionItem *nutritionItem = [WMNutritionItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == nutritionItem) {
        nutritionItem = [WMNutritionItem MR_createInContext:managedObjectContext];
        nutritionItem.title = title;
    }
    return nutritionItem;
}

#pragma mark - Seed

+ (WMNutritionItem *)updateNutritionItem:(WMNutritionItem *)nutritionItem
                          fromDictionary:(NSDictionary *)dictionary
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    if (nil == nutritionItem) {
        nutritionItem = [self nutritionItemForTitle:title
                                             create:YES
                               managedObjectContext:managedObjectContext];
    } else {
        nutritionItem.title = title;
    }
    nutritionItem.definition = [dictionary objectForKey:@"definition"];
    nutritionItem.loincCode = [dictionary objectForKey:@"LOINC Code"];
    nutritionItem.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    nutritionItem.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    nutritionItem.sortRank = [dictionary objectForKey:@"sortRank"];
    nutritionItem.valueTypeCode = [dictionary objectForKey:@"valueTypeCode"];
    return nutritionItem;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Nutrition" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"Nutrition.plist file not found");
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
            WMNutritionItem *nutritionItem = [self updateNutritionItem:nil fromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            [objectIDs addObject:[nutritionItem objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMNutritionItem entityName], nil);
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
                                                            @"groupValueTypeCode",
                                                            @"title",
                                                            @"value",
                                                            @"placeHolder",
                                                            @"unit",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"objectID",
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMNutritionItemRelationships.values]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMNutritionItem attributeNamesNotToSerialize] containsObject:propertyName] || [[WMNutritionItem relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMNutritionItem relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return [self.valueTypeCode intValue];
}

- (NSString *)placeHolder
{
    return nil;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    
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
    return [NSArray array];
}

- (NSSet *)interventionEvents
{
    return [NSSet set];
}

- (void)setInterventionEvents:(NSSet *)interventionEvents
{
}

@end

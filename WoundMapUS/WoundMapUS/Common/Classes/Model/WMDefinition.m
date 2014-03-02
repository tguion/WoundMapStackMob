#import "WMDefinition.h"
#import "WMDefinitionKeyword.h"
#import "SearchUtilities.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMDefinition ()

// Private interface goes here.

@end


@implementation WMDefinition

static NSDictionary *kDefinitionScope2DataFileMap;
static NSMutableCharacterSet *keywordDelimiters;

+ (void)initialize {
    kDefinitionScope2DataFileMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"WoundTypeDefinitions", [NSNumber numberWithInt:WoundPUMPScopeWoundType],
                                    @"WoundAssessmentDefinitions", [NSNumber numberWithInt:WoundPUMPScopeWoundAssessment],
                                    @"MedicationsDefinitions", [NSNumber numberWithInt:WoundPUMPScopeMedications],
                                    @"SkinAssessmentDefinitions", [NSNumber numberWithInt:WoundPUMPScopeMedications],
                                    @"WoundMeasurementDefinitions", [NSNumber numberWithInt:WoundPUMPScopeWoundMeasurement],
                                    @"WoundTreatmentDefinitions", [NSNumber numberWithInt:WoundPUMPScopeWoundTreatment],
                                    @"PsychoSocialDefinitions", [NSNumber numberWithInt:WoundPUMPScopeWoundPsychSocial],
                                    @"DeviceDefinitions", [NSNumber numberWithInt:WoundPUMPScopeWoundDevice],
                                    @"WoundPositionDefinitions", [NSNumber numberWithInt:WoundPUMPScopeWoundPosition],
                                    nil];
	keywordDelimiters = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
	[keywordDelimiters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"/-,()."]];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMDefinition *definition = [[WMDefinition alloc] initWithEntity:[NSEntityDescription entityForName:@"WMDefinition" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:definition toPersistentStore:store];
	}
    [definition setValue:[definition assignObjectId] forKey:[definition primaryKeyField]];
	return definition;
}

+ (NSInteger)definitionsCount:(NSManagedObjectContext *)managedObjectContext
              persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMDefinition" inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (WMDefinition *)definitionForTerm:(NSString *)term
                         definition:(NSString *)definition
                              scope:(WoundPUMPScope)scope
                             create:(BOOL)create
               managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                    persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMDefinition" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = nil;
    if (scope == WoundPUMPScopeAll) {
        predicate = [NSPredicate predicateWithFormat:@"term == %@", term];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"term == %@ AND scope == %d", term, scope];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMDefinition *result = [array lastObject];
    if (create && nil == result) {
        result = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        result.term = term;
        result.definition = definition;
        result.scope = [NSNumber numberWithInt:scope];
        [self updateKeywords:result
                   inserting:YES
        managedObjectContext:managedObjectContext
             persistentStore:store];
    }
    return result;
}

+ (NSInteger)updateKeywords:(WMDefinition *)definition
                  inserting:(BOOL)inserting
       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
            persistentStore:(NSPersistentStore *)store
{
	NSAssert([[definition managedObjectContext] isEqual:managedObjectContext], @"Invalid mocs");
	// remove current keywords
	if (!inserting) {
		for (WMDefinitionKeyword *keyword in definition.keywords) {
			[managedObjectContext deleteObject:keyword];
		}
		[definition removeKeywords:definition.keywords];
	}
	// break down string attributes
	NSString *string = nil;
    NSMutableSet *words = [[NSMutableSet alloc] initWithCapacity:32];
    if ([definition.term length] > 0) {
        string = [SearchUtilities normalizeString:definition.term];
        [words addObjectsFromArray:[string componentsSeparatedByCharactersInSet:keywordDelimiters]];
    }
	if ([definition.definition length]) {
		string = [SearchUtilities normalizeString:definition.definition];
		[words addObjectsFromArray:[string componentsSeparatedByCharactersInSet:keywordDelimiters]];
	}
	return [self addWordsAsKeywords:definition
                              words:[words allObjects]
               managedObjectContext:managedObjectContext
                    persistentStore:store];
}

+ (NSInteger)addWordsAsKeywords:(WMDefinition *)definition
                          words:(NSArray *)words
           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                persistentStore:(NSPersistentStore *)store
{
	NSAssert([[definition managedObjectContext] isEqual:managedObjectContext], @"Invalid mocs");
	NSInteger counter = 0;
	WMDefinitionKeyword *keyword = nil;
	for (NSString *word in words) {
		// check length
		if ([word length] < 3) {
			continue;
		}
		// else create
		NSString *trimmedWord = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		keyword = [WMDefinitionKeyword instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
		keyword.keyword = trimmedWord;
		keyword.definition = definition;
        keyword.scope = definition.scope;
		++counter;
	}
	return counter;
}

+ (NSPredicate *)predicateForSearchInput:(NSString *)searchString
{
    if ([searchString length] == 0) {
        return nil;
    }
    // else
	NSPredicate *predicate = nil;
	NSString *lowBound = [SearchUtilities normalizeString:searchString];
	NSString *highBound = [SearchUtilities upperBoundSearchString:lowBound];
	NSMutableDictionary *bindVariables = [[NSMutableDictionary alloc] init];
	[bindVariables setObject:lowBound forKey:@"lowBound"];
	[bindVariables setObject:highBound forKey:@"highBound"];
	predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(keywords, $keyword, $keyword.keyword >= %@ AND $keyword.keyword < %@).@count != 0", lowBound, highBound];
	return predicate;
}

+ (NSPredicate *)predicateForSearchInput:(NSString *)searchString section:(WoundPUMPScope)woundPUMPScope
{
    if ([searchString length] == 0) {
        return nil;
    }
    // else
	NSPredicate *predicate = nil;
	NSString *lowBound = [SearchUtilities normalizeString:searchString];
	NSString *highBound = [SearchUtilities upperBoundSearchString:lowBound];
	NSMutableDictionary *bindVariables = [[NSMutableDictionary alloc] init];
	[bindVariables setObject:lowBound forKey:@"lowBound"];
	[bindVariables setObject:highBound forKey:@"highBound"];
	predicate = [NSPredicate predicateWithFormat:
                 @"SUBQUERY(keywords, $keyword, $keyword.keyword >= %@ AND $keyword.keyword < %@ AND $keyword.scope == %d).@count != 0",
                 lowBound, highBound, woundPUMPScope];
	return predicate;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    if ([self definitionsCount:managedObjectContext persistentStore:store] > 0) {
        // already loaded
        return;
    }
    // else
    @autoreleasepool {
        NSError *error = nil;
        @autoreleasepool {
            for (id key in kDefinitionScope2DataFileMap) {
                NSString *fileName = [kDefinitionScope2DataFileMap objectForKey:key];
                NSURL *fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"plist"];
                if (nil == fileURL) {
                    DLog(@"%@.plist not found", fileName);
                    continue;
                }
                // else
                NSData *data = [NSData dataWithContentsOfURL:fileURL];
                id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                            options:NSPropertyListImmutable
                                                                             format:NULL
                                                                              error:&error];
                NSAssert1([propertyList isKindOfClass:[NSDictionary class]], @"Property list file did not return a dictionary, class was %@", NSStringFromClass([propertyList class]));
                [managedObjectContext performBlockAndWait:^{
                    NSInteger sortRank = 0;
                    for (NSString *term in propertyList) {
                        WMDefinition *definition = [WMDefinition definitionForTerm:term
                                                                        definition:[propertyList objectForKey:term]
                                                                             scope:[key intValue]
                                                                            create:YES
                                                              managedObjectContext:managedObjectContext
                                                                   persistentStore:store];
                        definition.sortRank = [NSNumber numberWithInt:sortRank++];
                    }
                }];
            }
        }
    }
}

@end

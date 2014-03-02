#import "WMWoundOdor.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMWoundOdor ()

// Private interface goes here.

@end


@implementation WMWoundOdor

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundOdor *woundOdor = [[WMWoundOdor alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundOdor" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundOdor toPersistentStore:store];
	}
    [woundOdor setValue:[woundOdor assignObjectId] forKey:[woundOdor primaryKeyField]];
	return woundOdor;
}

+ (WMWoundOdor *)woundOdorForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundOdor" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundOdor *woundOdor = [array lastObject];
    if (create && nil == woundOdor) {
        woundOdor = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundOdor.title = title;
    }
    return woundOdor;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundOdor" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WoundOdor.plist file not found");
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
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an NSArray, class was %@", NSStringFromClass([propertyList class]));
        for (NSDictionary *dictionary in propertyList) {
            [self updateWoundOdorFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

+ (WMWoundOdor *)updateWoundOdorFromDictionary:(NSDictionary *)dictionary
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundOdor *woundOdor = [WMWoundOdor woundOdorForTitle:title
                                                     create:YES
                                       managedObjectContext:managedObjectContext
                                            persistentStore:store];
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

@end

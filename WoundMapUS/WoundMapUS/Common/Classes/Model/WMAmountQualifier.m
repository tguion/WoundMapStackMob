#import "WMAmountQualifier.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMAmountQualifier ()

// Private interface goes here.

@end


@implementation WMAmountQualifier

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMAmountQualifier *amountQualifier = [[WMAmountQualifier alloc] initWithEntity:[NSEntityDescription entityForName:@"WMAmountQualifier" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:amountQualifier toPersistentStore:store];
	}
    [amountQualifier setValue:[amountQualifier assignObjectId] forKey:[amountQualifier primaryKeyField]];
	return amountQualifier;
}

+ (WMAmountQualifier *)amountQualifierForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMAmountQualifier" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMAmountQualifier *amountQualifier = [array lastObject];
    if (create && nil == amountQualifier) {
        amountQualifier = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        amountQualifier.title = title;
    }
    return amountQualifier;
}

+ (WMAmountQualifier *)updateAmountQualifierFromDictionary:(NSDictionary *)dictionary
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                           persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMAmountQualifier *amountQualifier = [self amountQualifierForTitle:title
                                                                create:YES
                                                  managedObjectContext:managedObjectContext
                                                       persistentStore:store];
    amountQualifier.loincCode = [dictionary objectForKey:@"LOINC Code"];
    amountQualifier.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    amountQualifier.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    amountQualifier.sortRank = [dictionary objectForKey:@"sortRank"];
    return amountQualifier;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"AmountQualifier" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"AmountQualifier.plist file not found");
		return;
	}
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an array, class was %@", NSStringFromClass([propertyList class]));
        for (NSDictionary *dictionary in propertyList) {
            [self updateAmountQualifierFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

@end

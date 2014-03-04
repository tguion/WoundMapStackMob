#import "WMBradenCare.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMBradenCare ()

// Private interface goes here.

@end


@implementation WMBradenCare

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMBradenCare *bradenCare = [[WMBradenCare alloc] initWithEntity:[NSEntityDescription entityForName:@"WMBradenCare" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:bradenCare toPersistentStore:store];
	}
    [bradenCare setValue:[bradenCare assignObjectId] forKey:[bradenCare primaryKeyField]];
	return bradenCare;
}

+ (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                   sortRank:(NSNumber *)sortRank
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (store) {
        [request setAffectedStores:@[store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMBradenCare" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"sectionTitle == %@ AND sortRank == %@", sectionTitle, sortRank]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return (WMBradenCare *)[array lastObject];
}

+ (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                      score:(NSNumber *)score
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (store) {
        [request setAffectedStores:@[store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMBradenCare" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"sectionTitle == %@ AND scoreMinimum <= %@ AND scoreMaximum >= %@", sectionTitle, score, score]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return (WMBradenCare *)[array lastObject];
}

#pragma mark - Seed

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"BradenCare" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"BradenCare.plist not found");
		return;
	}
	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:fileURL];
	id propertyList = [NSPropertyListSerialization propertyListWithData:data
																options:NSPropertyListImmutable
																 format:NULL
																  error:&error];
	NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an array, class was %@", NSStringFromClass([propertyList class]));
    [managedObjectContext performBlockAndWait:^{
        for (NSDictionary *dictionary in propertyList) {
            // attempt to fetch existing instance
            NSString *sectionTitle = [dictionary objectForKey:@"sectionTitle"];
            NSNumber *sortRank = [dictionary objectForKey:@"sortRank"];
            WMBradenCare *bradenCare = [WMBradenCare bradenCareForSectionTitle:sectionTitle sortRank:sortRank managedObjectContext:managedObjectContext persistentStore:store];
            if (nil == bradenCare) {
                bradenCare = [WMBradenCare instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
            }
            [bradenCare setValuesForKeysWithDictionary:dictionary];
        }
    }];
}


@end

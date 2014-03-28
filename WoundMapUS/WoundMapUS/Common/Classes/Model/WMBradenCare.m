#import "WMBradenCare.h"
#import "WMUtilities.h"

@interface WMBradenCare ()

// Private interface goes here.

@end


@implementation WMBradenCare

+ (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                   sortRank:(NSNumber *)sortRank
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMBradenCare MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"sectionTitle == %@ AND sortRank == %@", sectionTitle, sortRank] inContext:managedObjectContext];
}

+ (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                      score:(NSNumber *)score
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMBradenCare MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"sectionTitle == %@ AND scoreMinimum <= %@ AND scoreMaximum >= %@", sectionTitle, score, score] inContext:managedObjectContext];
}

#pragma mark - Seed

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"BradenCare" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"BradenCare.plist not found");
		return;
	}
    if ([WMBradenCare MR_countOfEntitiesWithContext:managedObjectContext]) {
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
        for (NSDictionary *dictionary in propertyList) {
            // attempt to fetch existing instance
            NSString *sectionTitle = [dictionary objectForKey:@"sectionTitle"];
            NSNumber *sortRank = [dictionary objectForKey:@"sortRank"];
            WMBradenCare *bradenCare = [WMBradenCare bradenCareForSectionTitle:sectionTitle sortRank:sortRank managedObjectContext:managedObjectContext];
            if (nil == bradenCare) {
                bradenCare = [WMBradenCare MR_createInContext:managedObjectContext];
            }
            [bradenCare setValuesForKeysWithDictionary:dictionary];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
    }
}


@end

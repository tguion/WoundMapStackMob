#import "WMAmountQualifier.h"
#import "WMUtilities.h"

@interface WMAmountQualifier ()

// Private interface goes here.

@end


@implementation WMAmountQualifier

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

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
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
            [self updateAmountQualifierFromDictionary:dictionary managedObjectContext:managedObjectContext];
        }
    }
}

@end

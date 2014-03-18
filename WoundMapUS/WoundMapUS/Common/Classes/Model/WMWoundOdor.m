#import "WMWoundOdor.h"
#import "WMUtilities.h"

@interface WMWoundOdor ()

// Private interface goes here.

@end


@implementation WMWoundOdor

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

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
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
            [self updateWoundOdorFromDictionary:dictionary managedObjectContext:managedObjectContext];
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

@end

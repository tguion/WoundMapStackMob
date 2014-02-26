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
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
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
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMBradenCare" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"sectionTitle == %@ AND scoreMinimum <= %@ AND scoreMaximum >= %@", sectionTitle, score, score]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return (WMBradenCare *)[array lastObject];
}

@end

#import "WMInterventionStatus.h"
#import "WMInterventionStatusJoin.h"
#import "WMUtilities.h"
#import "StackMob.h"

NSString * const kInterventionStatusPlanned = @"Planned";
NSString * const kInterventionStatusInProcess = @"In Process";
NSString * const kInterventionStatusCompleted = @"Completed";
NSString * const kInterventionStatusCancelled = @"Cancelled";
NSString * const kInterventionStatusDiscontinue = @"Discontinued";
NSString * const kInterventionStatusNotAdopted = @"Not Adopted";


@interface WMInterventionStatus ()

// Private interface goes here.

@end


@implementation WMInterventionStatus

- (BOOL)isActive
{
    return [self.activeFlag boolValue];
}

- (BOOL)isInProcess
{
    return [self.title isEqualToString:kInterventionStatusInProcess];
}

- (BOOL)canUpdateToStatus:(WMInterventionStatus *)interventionStatus
{
    return [[self.toStatusJoins valueForKeyPath:@"toStatus"] containsObject:interventionStatus];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMInterventionStatus *interventionStatus = [[WMInterventionStatus alloc] initWithEntity:[NSEntityDescription entityForName:@"WMInterventionStatus" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:interventionStatus toPersistentStore:store];
	}
    [interventionStatus setValue:[interventionStatus assignObjectId] forKey:[interventionStatus primaryKeyField]];
	return interventionStatus;
}

+ (WMInterventionStatus *)initialInterventionStatus:(NSManagedObjectContext *)managedObjectContext
{
    return [self interventionStatusForTitle:kInterventionStatusPlanned create:NO managedObjectContext:managedObjectContext persistentStore:nil];
}

+ (WMInterventionStatus *)completedInterventionStatus:(NSManagedObjectContext *)managedObjectContext
{
    return [self interventionStatusForTitle:kInterventionStatusCompleted create:NO managedObjectContext:managedObjectContext persistentStore:nil];
}

+ (WMInterventionStatus *)interventionStatusForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMInterventionStatus" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMInterventionStatus *interventionStatus = [array lastObject];
    if (create && nil == interventionStatus) {
        interventionStatus = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        interventionStatus.title = title;
    }
    return interventionStatus;
}

+ (WMInterventionStatus *)updateInterventionFromDictionary:(NSDictionary *)dictionary
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                           persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMInterventionStatus *interventionStatus = [self interventionStatusForTitle:title
                                                                         create:YES
                                                           managedObjectContext:managedObjectContext
                                                                persistentStore:store];
    interventionStatus.activeFlag = [dictionary objectForKey:@"activeFlag"];
    interventionStatus.definition = [dictionary objectForKey:@"definition"];
    interventionStatus.loincCode = [dictionary objectForKey:@"loincCode"];
    interventionStatus.snomedCID = [dictionary objectForKey:@"snomedCID"];
    interventionStatus.snomedFSN = [dictionary objectForKey:@"snomedFSN"];
    interventionStatus.sortRank = [dictionary objectForKey:@"sortRank"];
    return interventionStatus;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"InterventionStatus" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"InterventionStatus.plist file not found");
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
        NSAssert1([propertyList isKindOfClass:[NSDictionary class]], @"Property list file did not return a dictionary, class was %@", NSStringFromClass([propertyList class]));
        NSArray *array = [propertyList objectForKey:@"Statuses"];
        for (NSDictionary *dictionary in array) {
            [self updateInterventionFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
        array = [propertyList objectForKey:@"Joins"];
        for (NSDictionary *dictionary in array) {
            NSString *title = [[dictionary allKeys] lastObject];
            WMInterventionStatus *fromStatus = [WMInterventionStatus interventionStatusForTitle:title
                                                                                         create:NO
                                                                           managedObjectContext:managedObjectContext
                                                                                persistentStore:nil];
            NSAssert1(nil != fromStatus, @"No WMInterventionStatus for title %@", title);
            NSArray *values = [[[dictionary allValues] lastObject] componentsSeparatedByString:@","];
            for (NSString *value in values) {
                WMInterventionStatus *toStatus = [WMInterventionStatus interventionStatusForTitle:value
                                                                                           create:NO
                                                                             managedObjectContext:managedObjectContext
                                                                                  persistentStore:nil];
                NSAssert1(nil != toStatus, @"No WMInterventionStatus for title %@", value);
                [WCInterventionStatusJoin interventionStatusJoinFromStatus:fromStatus
                                                                  toStatus:toStatus
                                                                    create:YES
                                                      managedObjectContext:managedObjectContext];
            }
        }
    }
}

@end

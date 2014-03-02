#import "WMInterventionEventType.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"
#import "StackMob.h"

NSString * const kInterventionEventTypePlan = @"Plan";
NSString * const kInterventionEventTypeBegin = @"Begin";
NSString * const kInterventionEventTypeProvide = @"Provide";
NSString * const kInterventionEventTypeComplete = @"Complete";
NSString * const kInterventionEventTypeCancel = @"Cancel";
NSString * const kInterventionEventTypeDiscontinue = @"Discontinue";
NSString * const kInterventionEventTypeContinue = @"Continue";
NSString * const kInterventionEventTypeRevise = @"Revise";

@interface WMInterventionEventType ()

// Private interface goes here.

@end


@implementation WMInterventionEventType

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMInterventionEventType *interventionEventType = [[WMInterventionEventType alloc] initWithEntity:[NSEntityDescription entityForName:@"WMInterventionEventType" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:interventionEventType toPersistentStore:store];
	}
    [interventionEventType setValue:[interventionEventType assignObjectId] forKey:[interventionEventType primaryKeyField]];
	return interventionEventType;
}

+ (WMInterventionEventType *)interventionEventTypeForTitle:(NSString *)title
                                                    create:(BOOL)create
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                           persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMInterventionEventType" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMInterventionEventType *interventionEventType = [array lastObject];
    if (create && nil == interventionEventType) {
        interventionEventType = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        interventionEventType.title = title;
    }
    return interventionEventType;
}

+ (WMInterventionEventType *)interventionEventTypeForStatusTitle:(NSString *)title
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                 persistentStore:(NSPersistentStore *)store
{
    title = [self interventionEventTypeTitleForInterventionStatusTitle:title];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMInterventionEventType" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (NSString *)interventionEventTypeTitleForInterventionStatusTitle:(NSString *)title
{
    static NSDictionary *Status2TypeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Status2TypeMap = [[NSDictionary alloc] initWithObjectsAndKeys:
                          kInterventionEventTypePlan, kInterventionStatusPlanned,
                          kInterventionEventTypeBegin, kInterventionStatusInProcess,
                          kInterventionEventTypeComplete, kInterventionStatusCompleted,
                          kInterventionEventTypeCancel, kInterventionStatusCancelled,
                          kInterventionEventTypeDiscontinue, kInterventionStatusDiscontinue,
                          kInterventionEventTypeDiscontinue, kInterventionStatusNotAdopted,
                          nil];
    });
    return [Status2TypeMap objectForKey:title];
}

+ (NSString *)stringForChangeType:(InterventionEventChangeType)changeType
{
    NSString *string = @"";
    switch (changeType) {
        case InterventionEventChangeTypeNone: {
            // nothing
            break;
        }
        case InterventionEventChangeTypeDelete: {
            string = @"delete";
            break;
        }
        case InterventionEventChangeTypeAdd: {
            string = @"add";
            break;
        }
        case InterventionEventChangeTypeUpdateValue: {
            string = @"value";
            break;
        }
        case InterventionEventChangeTypeUpdateStatus: {
            string = @"status";
            break;
        }
    }
    return string;
}

+ (WMInterventionEventType *)updateInterventionEventTypeFromDictionary:(NSDictionary *)dictionary
                                                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                       persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMInterventionEventType *interventionEventType = [self interventionEventTypeForTitle:title
                                                                                  create:YES
                                                                    managedObjectContext:managedObjectContext
                                                                         persistentStore:store];
    interventionEventType.definition = [dictionary objectForKey:@"definition"];
    interventionEventType.loincCode = [dictionary objectForKey:@"loincCode"];
    interventionEventType.snomedCID = [dictionary objectForKey:@"snomedCID"];
    interventionEventType.snomedFSN = [dictionary objectForKey:@"snomedFSN"];
    interventionEventType.sortRank = [dictionary objectForKey:@"sortRank"];
    //    [WCUtilities saveChanges:managedObjectContext];
    return interventionEventType;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WCInterventionEventType" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WMInterventionEventType.plist file not found");
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
            [self updateInterventionEventTypeFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

@end

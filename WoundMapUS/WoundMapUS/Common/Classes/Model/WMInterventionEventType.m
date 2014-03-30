#import "WMInterventionEventType.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMInterventionEventType *)interventionEventTypeForTitle:(NSString *)title
                                                    create:(BOOL)create
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMInterventionEventType *interventionEventType = [WMInterventionEventType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == interventionEventType) {
        interventionEventType = [WMInterventionEventType MR_createInContext:managedObjectContext];
        interventionEventType.title = title;
    }
    return interventionEventType;
}

+ (WMInterventionEventType *)interventionEventTypeForStatusTitle:(NSString *)title
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMInterventionEventType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
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
{
    id title = [dictionary objectForKey:@"title"];
    WMInterventionEventType *interventionEventType = [self interventionEventTypeForTitle:title
                                                                                  create:YES
                                                                    managedObjectContext:managedObjectContext];
    interventionEventType.definition = [dictionary objectForKey:@"definition"];
    interventionEventType.loincCode = [dictionary objectForKey:@"loincCode"];
    interventionEventType.snomedCID = [dictionary objectForKey:@"snomedCID"];
    interventionEventType.snomedFSN = [dictionary objectForKey:@"snomedFSN"];
    interventionEventType.sortRank = [dictionary objectForKey:@"sortRank"];
    return interventionEventType;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler
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
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMInterventionEventType *interventionEventType = [self updateInterventionEventTypeFromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[interventionEventType objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[interventionEventType objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMInterventionEventType entityName]);
        }
    }
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"flagsValue",
                                        @"snomedCIDValue",
                                        @"sortRankValue"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMInterventionEventTypeRelationships.interventionEvents];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMInterventionEventType attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMInterventionEventType relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

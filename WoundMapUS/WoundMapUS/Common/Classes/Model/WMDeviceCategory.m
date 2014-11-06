#import "WMDeviceCategory.h"
#import "WMDevice.h"
#import "WMWoundType.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@interface WMDeviceCategory ()

// Private interface goes here.

@end


@implementation WMDeviceCategory

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMDeviceCategory *)deviceCategoryForTitle:(NSString *)title
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMDeviceCategory *deviceCategory = [WMDeviceCategory MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == deviceCategory) {
        deviceCategory = [WMDeviceCategory MR_createInContext:managedObjectContext];
        deviceCategory.title = title;
    }
    return deviceCategory;
}

+ (WMDeviceCategory *)deviceCategoryForSortRank:(id)sortRank
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMDeviceCategory MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"sortRank == %@", sortRank] inContext:managedObjectContext];
}

// Restrict to
+ (WMDeviceCategory *)updateDeviceCategory:(WMDeviceCategory *)deviceCategory
                            fromDictionary:(NSDictionary *)dictionary
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (nil == deviceCategory) {
        id title = [dictionary objectForKey:@"title"];
        deviceCategory = [self deviceCategoryForTitle:title
                                               create:YES
                                 managedObjectContext:managedObjectContext];
        deviceCategory.definition = [dictionary objectForKey:@"definition"];
        deviceCategory.loincCode = [dictionary objectForKey:@"LOINC Code"];
        deviceCategory.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
        deviceCategory.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
        deviceCategory.sortRank = [dictionary objectForKey:@"sortRank"];
        id woundTypeCodes = [dictionary objectForKey:@"woundTypeCodes"];
        if ([woundTypeCodes isKindOfClass:[NSString class]]) {
            NSArray *typeCodes = [woundTypeCodes componentsSeparatedByString:@","];
            NSMutableSet *set = [NSMutableSet set];
            for (id typeCode in typeCodes) {
                NSArray *woundTypes = [WMWoundType woundTypesForWoundTypeCode:[typeCode integerValue]
                                                         managedObjectContext:managedObjectContext];
                [set addObjectsFromArray:woundTypes];
            }
            [deviceCategory setWoundTypes:set];
        }
        return deviceCategory;
    }
    // else devices
    id devices = [dictionary objectForKey:@"devices"];
    for (NSDictionary *d in devices) {
        id title = [d objectForKey:@"title"];
        WMDevice *device = [WMDevice deviceForTitle:title create:YES managedObjectContext:managedObjectContext];
        device.definition = [d objectForKey:@"definition"];
        device.sortRank = [d objectForKey:@"sortRank"];
        device.loincCode = [d objectForKey:@"LOINC Code"];
        device.snomedCID = [d objectForKey:@"SNOMED CT CID"];
        device.snomedFSN = [d objectForKey:@"SNOMED CT FSN"];
        device.label = [d objectForKey:@"label"];
        device.options = [d objectForKey:@"options"];
        device.placeHolder = [d objectForKey:@"placeHolder"];
        device.valueTypeCode = [d objectForKey:@"inputTypeCode"];
        device.exludesOtherValues = [[d objectForKey:@"exludesOtherValues"] boolValue];
        device.category = deviceCategory;
    }
    return deviceCategory;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
    NSString *filename = @"Devices";
    if (TERRITORY_SUFFIX) {
        filename = [filename stringByAppendingString:TERRITORY_SUFFIX];
    }
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"Devices.plist file not found");
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
        NSMutableArray *deviceCategories = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMDeviceCategory *deviceCategory = [self updateDeviceCategory:nil fromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[deviceCategory objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[deviceCategory objectID]];
            [deviceCategories addObject:deviceCategory];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMDeviceCategory entityName], nil);
        }
        NSInteger index = 0;
        objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMDeviceCategory *deviceCategory = [deviceCategories objectAtIndex:index++];
            [self updateDeviceCategory:deviceCategory fromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            [objectIDs addObjectsFromArray:[[deviceCategory.devices allObjects] valueForKey:@"objectID"]];
        }
        if (completionHandler) {
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            dispatch_block_t block = ^{
                NSError *error = nil;
                for (WMDeviceCategory *deviceCategory in deviceCategories) {
                    for (WMDevice *device in deviceCategory.devices) {
                        [ff grabBagAdd:device to:deviceCategory grabBagName:WMDeviceCategoryRelationships.devices error:&error];
                        if (error) {
                            [WMUtilities logError:error];
                        }
                    }
                }
            };
            completionHandler(nil, objectIDs, [WMDevice entityName], block);
        }
    }
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return nil;
}

- (BOOL)requireUpdatesFromCloud
{
    return NO;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"snomedCIDValue",
                                                            @"sortRankValue",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMDeviceCategory attributeNamesNotToSerialize] containsObject:propertyName] || [[WMDeviceCategory relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMDeviceCategory relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

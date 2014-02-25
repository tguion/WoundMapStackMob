#import "WMDeviceCategory.h"
#import "WMDevice.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMDeviceCategory ()

// Private interface goes here.

@end


@implementation WMDeviceCategory

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMDeviceCategory *deviceCategory = [[WMDeviceCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"WMDeviceCategory" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:deviceCategory toPersistentStore:store];
	}
    [deviceCategory setValue:[deviceCategory assignObjectId] forKey:[deviceCategory primaryKeyField]];
	return deviceCategory;
}

+ (WMDeviceCategory *)deviceCategoryForTitle:(NSString *)title
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMDeviceCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMDeviceCategory *deviceCategory = [array lastObject];
    if (create && nil == deviceCategory) {
        deviceCategory = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        deviceCategory.title = title;
    }
    return deviceCategory;
}

+ (WMDeviceCategory *)deviceCategoryForSortRank:(id)sortRank
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMDeviceCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"sortRank == %@", sortRank]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

// Restrict to
+ (WMDeviceCategory *)updateDeviceCategoryFromDictionary:(NSDictionary *)dictionary
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                         persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMDeviceCategory *deviceCategory = [self deviceCategoryForTitle:title
                                                             create:YES
                                               managedObjectContext:managedObjectContext
                                                    persistentStore:store];
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
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
            [set addObjectsFromArray:woundTypes];
        }
        [deviceCategory setWoundTypes:set];
    }
    // devices
    id devices = [dictionary objectForKey:@"devices"];
    for (NSDictionary *d in devices) {
        title = [d objectForKey:@"title"];
        WMDevice *device = [WMDevice deviceForTitle:title create:YES managedObjectContext:managedObjectContext persistentStore:store];
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

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Devices" withExtension:@"plist"];
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
        __weak __typeof(self) weakSelf = self;
        [managedObjectContext performBlockAndWait:^{
            for (NSDictionary *dictionary in propertyList) {
                [weakSelf updateDeviceCategoryFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
            }
        }];
    }
}

@end

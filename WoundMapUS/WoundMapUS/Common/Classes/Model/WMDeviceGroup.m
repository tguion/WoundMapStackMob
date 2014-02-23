#import "WMDeviceGroup.h"
#import "WMDeviceValue.h"
#import "WMDevice.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMDeviceGroup ()

// Private interface goes here.

@end


@implementation WMDeviceGroup

- (NSArray *)devices
{
    return [self.values valueForKeyPath:@"device"];
}

- (NSArray *)sortedDeviceValues
{
    return [[self.values allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"device.category.sortRank" ascending:YES],
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"device.sortRank" ascending:YES],
                                                                  nil]];
}

- (BOOL)isClosed
{
    return [self.closedFlag boolValue];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMDeviceGroup *deviceGroup = [[WMDeviceGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMDeviceGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:deviceGroup toPersistentStore:store];
	}
    [deviceGroup setValue:[deviceGroup assignObjectId] forKey:[deviceGroup primaryKeyField]];
	return deviceGroup;
}

- (BOOL)removeExcludesOtherValues
{
    BOOL result = NO;
    NSArray *values = [self.values allObjects];
    for (WMDeviceValue *value in values) {
        if (value.device.exludesOtherValues) {
            [self removeValuesObject:value];
            [[self managedObjectContext] deleteObject:value];
            result = YES;
        }
    }
    return result;
}

+ (BOOL)deviceGroupsHaveHistory:(NSManagedObjectContext *)managedObjectContext
{
    return [self deviceGroupsCount:managedObjectContext] > 1;
}

+ (NSInteger)deviceGroupsCount:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMDeviceGroup" inManagedObjectContext:managedObjectContext]];
    __block NSInteger count = 0;
    [managedObjectContext performBlockAndWait:^{
        count = [managedObjectContext countForFetchRequest:request error:NULL];
    }];
    return count;
}

+ (WMDeviceGroup *)deviceGroupByRevising:(WMDeviceGroup *)deviceGroup
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (nil == deviceGroup) {
        return [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
    }
    // TODO else
    
    return nil;
}

+ (WMDeviceGroup *)activeDeviceGroup:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMDeviceGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"closedFlag == NO"]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (NSInteger)closeDeviceGroupsCreatedBefore:(NSDate *)date
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:@[store]];
    }
	[request setEntity:[NSEntityDescription entityForName:@"WMDeviceGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"closedFlag == NO AND dateCreated < %@", date]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        [WMUtilities logError:error];
        return 0;
    }
	// else
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (WMDeviceGroup *)mostRecentOrActiveDeviceGroup:(NSManagedObjectContext *)managedObjectContext
{
    WMDeviceGroup *deviceGroup = [self activeDeviceGroup:managedObjectContext];
    if (nil == deviceGroup) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"WMDeviceGroup" inManagedObjectContext:managedObjectContext]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:YES]]];
        NSError *error = nil;
        NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
        if (nil != error) {
            [WMUtilities logError:error];
        }
        // else
        deviceGroup = [array lastObject];
    }
    return deviceGroup;
}

+ (NSDate *)mostRecentOrActiveDeviceGroupDateModified:(NSManagedObjectContext *)managedObjectContext
{
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"dateModified"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"dateModified";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMDeviceGroup"];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if ([results count] == 0)
        return nil;
    // else
    NSDictionary *dates = [results firstObject];
    return dates[@"dateModified"];
}

+ (NSArray *)sortedDeviceGroups:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMDeviceGroup" inManagedObjectContext:managedObjectContext]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.dateModified = [NSDate date];
}

- (WMDeviceValue *)deviceValueForDevice:(WMDevice *)device
                                 create:(BOOL)create
                                  value:(NSString *)value
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    device = (WMDevice *)[managedObjectContext objectWithID:[device objectID]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMDeviceValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND device == %@", self, device];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
    // else
    WMDeviceValue *deviceValue = [array lastObject];
    if (create && nil == deviceValue) {
        deviceValue = [WMDeviceValue instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        deviceValue.device = device;
        deviceValue.value = value;
        deviceValue.title = device.title;
        [self addValuesObject:deviceValue];
    }
    return deviceValue;
}

- (void)incrementContinueCount
{
    self.continueCount = [NSNumber numberWithInt:([self.continueCount intValue] + 1)];
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return GroupValueTypeCodeSelect;
}

- (NSString *)title
{
    return nil;
}

- (void)setTitle:(NSString *)title
{
    
}

- (NSString *)placeHolder
{
    return nil;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    
}

- (NSArray *)secondaryOptionsArray
{
    return self.optionsArray;
}

- (NSString *)unit
{
    return nil;
}

- (void)setUnit:(NSString *)unit
{
}

- (id)value
{
    return nil;
}

- (void)setValue:(id)value
{
}

- (NSArray *)optionsArray
{
    return [NSArray array];
}

@end

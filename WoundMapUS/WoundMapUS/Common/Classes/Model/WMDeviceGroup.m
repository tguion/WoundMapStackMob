#import "WMDeviceGroup.h"
#import "WMPatient.h"
#import "WMDeviceValue.h"
#import "WMDevice.h"
#import "WMUtilities.h"

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

+ (BOOL)deviceGroupsHaveHistory:(WMPatient *)patient
{
    return [self deviceGroupsCount:patient] > 1;
}

+ (NSInteger)deviceGroupsCount:(WMPatient *)patient
{
    return [WMDeviceGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

+ (WMDeviceGroup *)activeDeviceGroup:(WMPatient *)patient
{
    return [WMDeviceGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO", patient] sortedBy:@"updatedAt" ascending:NO inContext:[patient managedObjectContext]];
}

+ (NSInteger)closeDeviceGroupsCreatedBefore:(NSDate *)date
                                    patient:(WMPatient *)patient
{
    NSArray *array = [WMDeviceGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND dateCreated < %@", patient, date] inContext:[patient managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (WMDeviceGroup *)mostRecentOrActiveDeviceGroup:(WMPatient *)patient
{
    WMDeviceGroup *deviceGroup = [self activeDeviceGroup:patient];
    if (nil == deviceGroup) {
        deviceGroup = [WMDeviceGroup MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO inContext:[patient managedObjectContext]];
    }
    return deviceGroup;
}

+ (NSDate *)mostRecentOrActiveDeviceGroupDateModified:(WMPatient *)patient
{
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMDeviceGroup"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *dates = (NSDictionary *)[WMDeviceGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:[patient managedObjectContext]];
    return dates[@"updatedAt"];
}

+ (NSArray *)sortedDeviceGroups:(WMPatient *)patient
{
    return [WMDeviceGroup MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (WMDeviceValue *)deviceValueForDevice:(WMDevice *)device
                                 create:(BOOL)create
                                  value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSParameterAssert(managedObjectContext == [device managedObjectContext]);
    WMDeviceValue *deviceValue = [WMDeviceValue MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND device == %@", self, device] inContext:managedObjectContext];
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

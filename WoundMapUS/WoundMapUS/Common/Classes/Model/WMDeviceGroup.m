#import "WMDeviceGroup.h"
#import "WMPatient.h"
#import "WMDeviceValue.h"
#import "WMDevice.h"
#import "WMInterventionStatus.h"
#import "WMDeviceInterventionEvent.h"
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
    NSArray *array = [WMDeviceGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND createdAt < %@", patient, date] inContext:[patient managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (WMDeviceGroup *)deviceGroupForPatient:(WMPatient *)patient
{
    WMDeviceGroup *deviceGroup = [WMDeviceGroup MR_createInContext:[patient managedObjectContext]];
    deviceGroup.patient = patient;
    return deviceGroup;
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
    // initial status
    self.status = [WMInterventionStatus initialInterventionStatus:[self managedObjectContext]];
}

- (BOOL)hasInterventionEvents
{
    return [self.interventionEvents count] > 0;
}

- (WMDeviceValue *)deviceValueForDevice:(WMDevice *)device
                                 create:(BOOL)create
                                  value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSParameterAssert(managedObjectContext == [device managedObjectContext]);
    WMDeviceValue *deviceValue = [WMDeviceValue MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND device == %@", self, device] inContext:managedObjectContext];
    if (create && nil == deviceValue) {
        deviceValue = [WMDeviceValue MR_createInContext:managedObjectContext];
        deviceValue.device = device;
        deviceValue.value = value;
        deviceValue.title = device.title;
        [self addValuesObject:deviceValue];
    }
    return deviceValue;
}

#pragma mark - Events

- (WMDeviceInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                        title:(NSString *)title
                                                    valueFrom:(id)valueFrom
                                                      valueTo:(id)valueTo
                                                         type:(WMInterventionEventType *)type
                                                  participant:(WMParticipant *)participant
                                                       create:(BOOL)create
                                         managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMDeviceInterventionEvent *event = [WMDeviceInterventionEvent deviceInterventionEventForDeviceGroup:self
                                                                                             changeType:changeType
                                                                                                  title:title
                                                                                              valueFrom:valueFrom
                                                                                                valueTo:valueTo
                                                                                                   type:type
                                                                                            participant:participant
                                                                                                 create:create
                                                                                   managedObjectContext:managedObjectContext];
    return event;
}

- (NSArray *)deviceValuesAdded
{
    NSDictionary *committedValuesMap = [self committedValuesForKeys:@[@"values"]];
    NSSet *committedValues = [committedValuesMap objectForKey:@"values"];
    if ([committedValues isKindOfClass:[NSNull class]]) {
        return @[];
    }
    // else
    NSMutableSet *addedValues = [self.values mutableCopy];
    [addedValues minusSet:committedValues];
    return [addedValues allObjects];
}

- (NSArray *)deviceValuesRemoved
{
    NSDictionary *committedValuesMap = [self committedValuesForKeys:@[@"values"]];
    NSSet *committedValues = [committedValuesMap objectForKey:@"values"];
    if ([committedValues isKindOfClass:[NSNull class]]) {
        return @[];
    }
    // else
    NSMutableSet *deletedValues = [committedValues mutableCopy];
    [deletedValues minusSet:self.values];
    return [deletedValues allObjects];
}

- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant
{
    NSArray *addedValues = self.deviceValuesAdded;
    NSArray *deletedValues = self.deviceValuesRemoved;
    NSMutableArray *events = [NSMutableArray array];
    for (WMDeviceValue *deviceValue in addedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeAdd
                                                         title:deviceValue.title
                                                     valueFrom:nil
                                                       valueTo:deviceValue.value
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created add event %@", deviceValue.title);
    }
    for (WMDeviceValue *deviceValue in deletedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeDelete
                                                         title:deviceValue.title
                                                     valueFrom:nil
                                                       valueTo:nil
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created delete event %@", deviceValue.title);
    }
    for (WMDeviceValue *deviceValue in [self.managedObjectContext updatedObjects]) {
        if ([deviceValue isKindOfClass:[WMDeviceValue class]]) {
            NSDictionary *committedValuesMap = [deviceValue committedValuesForKeys:@[@"values"]];
            NSString *oldValue = [committedValuesMap objectForKey:@"value"];
            NSString *newValue = deviceValue.value;
            if ([oldValue isEqualToString:newValue]) {
                continue;
            }
            // else it changed
            [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeUpdateValue
                                                             title:deviceValue.device.title
                                                         valueFrom:oldValue
                                                           valueTo:newValue
                                                              type:nil
                                                       participant:participant
                                                            create:YES
                                              managedObjectContext:self.managedObjectContext]];
            DLog(@"Created event %@->%@", oldValue, newValue);
        }
    }
    return events;
}

- (void)incrementContinueCount
{
    self.continueCount = [NSNumber numberWithInt:([self.continueCount intValue] + 1)];
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"closedFlagValue",
                                        @"continueCountValue",
                                        @"flagsValue",
                                        @"groupValueTypeCode",
                                        @"unit",
                                        @"value",
                                        @"optionsArray",
                                        @"secondaryOptionsArray",
                                        @"interventionEvents",
                                        @"devices",
                                        @"hasInterventionEvents",
                                        @"sortedDeviceValues",
                                        @"isClosed",
                                        @"deviceValuesAdded",
                                        @"deviceValuesRemoved"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMDeviceGroupRelationships.interventionEvents,
                                        WMDeviceGroupRelationships.values];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMDeviceGroup attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMDeviceGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
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

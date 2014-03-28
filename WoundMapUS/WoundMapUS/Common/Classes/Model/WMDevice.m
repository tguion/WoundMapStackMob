#import "WMDevice.h"
#import "WMUtilities.h"

typedef enum {
    WCDeviceExludeOtherValues             = 0,
} WMDeviceFlags;

@interface WMDevice ()

// Private interface goes here.

@end


@implementation WMDevice

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMDevice *)deviceForTitle:(NSString *)title
                      create:(BOOL)create
        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMDevice *device = [WMDevice MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == device) {
        device = [WMDevice MR_createInContext:managedObjectContext];
        device.title = title;
    }
    return device;
}

+ (WMDevice *)updateDeviceFromDictionary:(NSDictionary *)dictionary
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMDevice *device = [self deviceForTitle:title
                                     create:YES
                       managedObjectContext:managedObjectContext];
    device.definition = [dictionary objectForKey:@"definition"];
    device.loincCode = [dictionary objectForKey:@"LOINC Code"];
    device.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    device.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    device.sortRank = [dictionary objectForKey:@"sortRank"];
    device.label = [dictionary objectForKey:@"label"];
    device.options = [dictionary objectForKey:@"options"];
    device.placeHolder = [dictionary objectForKey:@"placeHolder"];
    device.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    device.exludesOtherValues = [[dictionary objectForKey:@"exludesOtherValues"] boolValue];
    return device;
}

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return nil;
    }
    // else include all WMDevice instances where category has no woundTypes OR has wound type included
    // !(ANY excludedOccurrences.start >= %@ AND ANY excludedOccurrences.start <= %@)
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE excludedDay.day == %@", today];
    return [NSPredicate predicateWithFormat:@"category.woundTypes.@count == 0 OR ANY category.woundTypes == %@", woundType];
}

- (BOOL)exludesOtherValues
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WCDeviceExludeOtherValues];
}

- (void)setExludesOtherValues:(BOOL)exludesOtherValues
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WCDeviceExludeOtherValues to:exludesOtherValues]);
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"flagsValue",
                                        @"snomedCIDValue",
                                        @"sortRankValue",
                                        @"valueTypeCodeValue",
                                        @"groupValueTypeCode",
                                        @"unit",
                                        @"value",
                                        @"optionsArray",
                                        @"secondaryOptionsArray",
                                        @"interventionEvents",
                                        @"exludesOtherValues"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMDeviceRelationships.values];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMDevice attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMDevice relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return [self.valueTypeCode intValue];
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
    return [self.options componentsSeparatedByString:@","];
}

- (NSArray *)secondaryOptionsArray
{
    return self.optionsArray;
}

- (NSSet *)interventionEvents
{
    return [NSSet set];
}

- (void)setInterventionEvents:(NSSet *)interventionEvents
{
}

@end

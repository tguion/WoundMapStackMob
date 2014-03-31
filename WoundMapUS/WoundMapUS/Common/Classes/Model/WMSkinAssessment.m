#import "WMSkinAssessment.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

@interface WMSkinAssessment ()

// Private interface goes here.

@end


@implementation WMSkinAssessment

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMSkinAssessment *)skinInspectionForTitle:(NSString *)title
                                    category:(WMSkinAssessmentCategory *)category
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMSkinAssessment *skinInspection = [WMSkinAssessment MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND category == %@", title, category] inContext:managedObjectContext];
    if (create && nil == skinInspection) {
        skinInspection = [WMSkinAssessment MR_createInContext:managedObjectContext];
        skinInspection.title = title;
    }
    return skinInspection;
}

+ (WMSkinAssessment *)updateSkinAssessmentFromDictionary:(NSDictionary *)dictionary
                                                category:(WMSkinAssessmentCategory *)category
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMSkinAssessment *skinInspection = [self skinInspectionForTitle:title
                                                           category:category
                                                             create:YES
                                               managedObjectContext:managedObjectContext];
    skinInspection.definition = [dictionary objectForKey:@"definition"];
    skinInspection.loincCode = [dictionary objectForKey:@"LOINC Code"];
    skinInspection.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    skinInspection.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    skinInspection.sortRank = [dictionary objectForKey:@"sortRank"];
    skinInspection.label = [dictionary objectForKey:@"label"];
    skinInspection.options = [dictionary objectForKey:@"options"];
    skinInspection.placeHolder = [dictionary objectForKey:@"placeHolder"];
    skinInspection.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    return skinInspection;
}

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return nil;
    }
    // else
    return [NSPredicate predicateWithFormat:@"category.woundTypes.@count == 0 OR ANY category.woundTypes == %@", woundType];
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
                                                            @"valueTypeCodeValue",
                                                            @"groupValueTypeCode",
                                                            @"unit",
                                                            @"value",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"interventionEvents"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMSkinAssessmentRelationships.values]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMSkinAssessment attributeNamesNotToSerialize] containsObject:propertyName] || [[WMSkinAssessment relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMSkinAssessment relationshipNamesNotToSerialize] containsObject:propertyName]) {
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

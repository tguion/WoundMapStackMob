#import "WMMedication.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

typedef enum {
    WMMedicationExludeOtherValues             = 0,
} WMMedicationFlags;

@interface WMMedication ()

// Private interface goes here.

@end


@implementation WMMedication

- (BOOL)exludesOtherValues
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMMedicationExludeOtherValues];
}

- (void)setExludesOtherValues:(BOOL)exludesOtherValues
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMMedicationExludeOtherValues to:exludesOtherValues]);
}

+ (WMMedication *)medicationForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMMedication *medication = [WMMedication MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == medication) {
        medication = [WMMedication MR_createInContext:managedObjectContext];
        medication.title = title;
    }
    return medication;
}

+ (WMMedication *)updateMedicationFromDictionary:(NSDictionary *)dictionary
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMMedication *medication = [self medicationForTitle:title
                                                 create:YES
                                   managedObjectContext:managedObjectContext];
    medication.definition = [dictionary objectForKey:@"definition"];
    medication.loincCode = [dictionary objectForKey:@"LOINC Code"];
    medication.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    medication.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    medication.sortRank = [dictionary objectForKey:@"sortRank"];
    medication.exludesOtherValues = [[dictionary objectForKey:@"exludesOtherValues"] boolValue];
    return medication;
}

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return nil;
    }
    // else
    return [NSPredicate predicateWithFormat:@"category.woundTypes.@count == 0 OR ANY category.woundTypes == %@", woundType];
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return GroupValueTypeCodeSelect;
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

- (NSString *)placeHolder
{
    return nil;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
}

- (NSArray *)optionsArray
{
    return [NSArray array];
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

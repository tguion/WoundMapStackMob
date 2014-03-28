#import "WMWoundPosition.h"
#import "WMWoundLocation.h"
#import "WMUtilities.h"

typedef enum {
    WoundPositionFlagsOptionsInline             = 0,
    WoundPositionFlagsAllowMultipleSelection    = 1,
} WoundPositionFlags;

@interface WMWoundPosition ()

// Private interface goes here.

@end


@implementation WMWoundPosition

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)optionsInline
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundPositionFlagsOptionsInline];
}

- (void)setOptionsInline:(BOOL)optionsInline
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundPositionFlagsOptionsInline to:optionsInline]);
}

- (BOOL)allowMultipleSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundPositionFlagsAllowMultipleSelection];
}

- (void)setAllowMultipleSelection:(BOOL)allowMultipleSelection
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundPositionFlagsAllowMultipleSelection to:allowMultipleSelection]);
}

- (BOOL)hasTitle
{
    return [self.title length] > 0;
}

+ (WMWoundPosition *)woundPositionForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundPosition *woundPosition = [WMWoundPosition MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == woundPosition) {
        woundPosition = [WMWoundPosition MR_createInContext:managedObjectContext];
        woundPosition.title = title;
    }
    return woundPosition;
}

+ (WMWoundPosition *)woundPositionForCommonTitle:(NSString *)commonTitle
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundPosition *woundPosition = [WMWoundPosition MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"commonTitle == %@", commonTitle] inContext:managedObjectContext];
    if (create && nil == woundPosition) {
        woundPosition = [WMWoundPosition MR_createInContext:managedObjectContext];
        woundPosition.commonTitle = commonTitle;
    }
    return woundPosition;
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
                                        @"optionsInline",
                                        @"allowMultipleSelection",
                                        @"hasTitle"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMWoundPositionRelationships.positionValues];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundPosition attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundPosition relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

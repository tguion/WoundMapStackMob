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

@end

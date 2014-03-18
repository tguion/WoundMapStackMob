#import "WMWoundPositionValue.h"
#import "WMWound.h"

@interface WMWoundPositionValue ()

// Private interface goes here.

@end


@implementation WMWoundPositionValue

+ (WMWoundPositionValue *)woundPositionValueForWound:(WMWound *)wound
{
    WMWoundPositionValue *woundPositionValue = [WMWoundPositionValue MR_createInContext:[wound managedObjectContext]];
    woundPositionValue.wound = wound;
    return woundPositionValue;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end

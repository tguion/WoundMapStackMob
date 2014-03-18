#import "WMWoundLocationValue.h"
#import "WMWound.h"

@interface WMWoundLocationValue ()

// Private interface goes here.

@end


@implementation WMWoundLocationValue

+ (WMWoundLocationValue *)woundLocationValueForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    WMWoundLocationValue *woundLocationValue = [WMWoundLocationValue MR_createInContext:managedObjectContext];
    woundLocationValue.wound = wound;
    return woundLocationValue;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end

#import "WMDeviceValue.h"

@interface WMDeviceValue ()

// Private interface goes here.

@end


@implementation WMDeviceValue

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end

#import "WMPhoto.h"

@interface WMPhoto ()

// Private interface goes here.

@end


@implementation WMPhoto

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end

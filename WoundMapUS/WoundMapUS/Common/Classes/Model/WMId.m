#import "WMId.h"

@interface WMId ()

// Private interface goes here.

@end


@implementation WMId

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end

#import "WMInterventionEvent.h"


@interface WMInterventionEvent ()

// Private interface goes here.

@end


@implementation WMInterventionEvent

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    self.dateEvent = [NSDate date];
}

@end

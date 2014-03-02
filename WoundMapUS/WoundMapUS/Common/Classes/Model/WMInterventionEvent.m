#import "WMInterventionEvent.h"


@interface WMInterventionEvent ()

// Private interface goes here.

@end


@implementation WMInterventionEvent

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateEvent = [NSDate date];
}

@end

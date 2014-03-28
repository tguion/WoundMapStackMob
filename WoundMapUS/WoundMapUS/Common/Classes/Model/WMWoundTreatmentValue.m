#import "WMWoundTreatmentValue.h"

@interface WMWoundTreatmentValue ()

// Private interface goes here.

@end


@implementation WMWoundTreatmentValue

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

@end

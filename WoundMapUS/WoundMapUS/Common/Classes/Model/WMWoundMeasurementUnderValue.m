#import "WMWoundMeasurementUnderValue.h"

@interface WMWoundMeasurementUnderValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementUnderValue

- (NSString *)labelText
{
    return @"Undermining";
}

- (NSString *)valueText
{
    return [NSString stringWithFormat:@"%@-%@ O'Clock %@ cm", self.fromOClockValue, self.toOClockValue, ([self.value length] > 0 ? self.value:@"?")];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.sectionTitle = @"Undermining";
}

- (NSString *)displayValue
{
    return self.valueText;
}

@end

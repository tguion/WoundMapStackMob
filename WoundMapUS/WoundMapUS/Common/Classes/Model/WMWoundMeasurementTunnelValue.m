#import "WMWoundMeasurementTunnelValue.h"

@interface WMWoundMeasurementTunnelValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementTunnelValue

- (NSString *)labelText
{
    return @"Tunneling";
}

- (NSString *)valueText
{
    return [NSString stringWithFormat:@"%@ O'Clock %@ cm", self.fromOClockValue, ([self.value length] > 0 ? self.value:@"?")];
}

- (NSString *)displayValue
{
    return self.valueText;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.sectionTitle = @"Tunneling";
}

@end

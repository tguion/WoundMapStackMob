#import "WMWoundMeasurementValue.h"
#import "WMWoundMeasurement.h"
#import "WMAmountQualifier.h"
#import "WMWoundOdor.h"

@interface WMWoundMeasurementValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementValue

- (NSString *)displayValue
{
    NSString *displayValue = nil;
    if (nil == self.value) {
        displayValue = self.amountQualifier.title;
        if (nil == displayValue) {
            displayValue = self.odor.title;
            if (nil == displayValue) {
                displayValue = self.woundMeasurement.title;
            }
        }
    } else {
        switch (self.woundMeasurement.groupValueTypeCode) {
            case GroupValueTypeCodeInlineExtendsTextField:
                displayValue = [NSString stringWithFormat:@"Extends out %@ cm", self.value];
                break;
            default:
                displayValue = self.value;
                break;
        }
    }
    return displayValue;
}

@end

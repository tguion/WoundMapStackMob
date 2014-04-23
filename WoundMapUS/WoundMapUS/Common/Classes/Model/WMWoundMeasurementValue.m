#import "WMWoundMeasurementValue.h"
#import "WMWoundMeasurement.h"
#import "WMAmountQualifier.h"
#import "WMWoundOdor.h"

@interface WMWoundMeasurementValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementValue

+ (instancetype)normalWoundMeasurementValue:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundMeasurementValue *value = [WMWoundMeasurementValue MR_createInContext:managedObjectContext];
    value.woundMeasurementValueType = @(kWoundMeasurementValueTypeNormal);
    return value;
}

+ (instancetype)tunnelWoundMeasurementValue:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundMeasurementValue *value = [WMWoundMeasurementValue MR_createInContext:managedObjectContext];
    value.woundMeasurementValueType = @(kWoundMeasurementValueTypeTunnel);
    value.sectionTitle = @"Tunneling";
    return value;
}

+ (instancetype)undermineWoundMeasurementValue:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundMeasurementValue *value = [WMWoundMeasurementValue MR_createInContext:managedObjectContext];
    value.woundMeasurementValueType = @(kWoundMeasurementValueTypeUndermine);
    value.sectionTitle = @"Undermining";
    return value;
}

- (BOOL)isTunnelingValue
{
    return self.woundMeasurementValueTypeValue == kWoundMeasurementValueTypeTunnel;
}

- (BOOL)isUnderminingValue
{
    return self.woundMeasurementValueTypeValue == kWoundMeasurementValueTypeUndermine;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (NSString *)labelText
{
    NSString *labelText = nil;
    switch ([self.woundMeasurementValueType intValue]) {
        case kWoundMeasurementValueTypeNormal: {
            break;
        }
        case kWoundMeasurementValueTypeTunnel: {
            labelText = @"Tunneling";
            break;
        }
        case kWoundMeasurementValueTypeUndermine: {
            labelText = @"Undermining";
            break;
        }
    }
    return labelText;
}
- (NSString *)valueText
{
    NSString *valueText = nil;
    switch ([self.woundMeasurementValueType intValue]) {
        case kWoundMeasurementValueTypeNormal: {
            break;
        }
        case kWoundMeasurementValueTypeTunnel: {
            valueText = [NSString stringWithFormat:@"%@ O'Clock %@ cm", self.fromOClockValue, ([self.value length] > 0 ? self.value:@"?")];
            break;
        }
        case kWoundMeasurementValueTypeUndermine: {
            valueText = [NSString stringWithFormat:@"%@-%@ O'Clock %@ cm", self.fromOClockValue, self.toOClockValue, ([self.value length] > 0 ? self.value:@"?")];
            break;
        }
    }
    return valueText;
}

- (NSString *)displayValue
{
    NSString *displayValue = nil;
    switch ([self.woundMeasurementValueType intValue]) {
        case kWoundMeasurementValueTypeNormal: {
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
            break;
        }
        case kWoundMeasurementValueTypeTunnel: {
            displayValue = self.valueText;
            break;
        }
        case kWoundMeasurementValueTypeUndermine: {
            displayValue = self.valueText;
            break;
        }
    }
    return displayValue;
}
//, , , , , , , , , ,
#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"fromOClockValueValue",
                                                            @"revisedFlagValue",
                                                            @"sortRankValue",
                                                            @"toOClockValueValue",
                                                            @"woundMeasurementValueTypeValue",
                                                            @"isUnderminingValue",
                                                            @"displayValue",
                                                            @"valueText",
                                                            @"labelText",
                                                            @"isTunnelingValue"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundMeasurementValue attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundMeasurementValue relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundMeasurementValue relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

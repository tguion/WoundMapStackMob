//
//  WMWoundMeasurementGroup+CoreText.m
//  WoundMAP
//
//  Created by etreasure consulting LLC on 12/22/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundMeasurementGroup+CoreText.h"
#import "WMWound.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurement.h"
#import "WMWoundMeasurementValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMWoundMeasurementGroup (CoreText)

#pragma mark - WCCoreTextDataSource

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = [@"Wound Assessment for " stringByAppendingString:self.wound.shortName];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    // date modified
    string = [NSDateFormatter localizedStringFromDate:self.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    currentFontSize = fontSize - 2.0;
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // get attributes for sections
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    // start with root wound measurements
    NSArray *woundMeasurements = [WMWoundMeasurement sortedRootWoundMeasurements:managedObjectContext];
    for (WMWoundMeasurement *woundMeasurement in woundMeasurements) {
        // get values associated with woundMeasurement OR with children of woundMeasurement
        NSArray *woundMeasurementValues = nil;
        if (woundMeasurement.hasChildrenWoundMeasurements) {
            woundMeasurementValues = [self woundMeasurementValuesForParentWoundMeasurement:woundMeasurement];
        } else {
            woundMeasurementValues = [self woundMeasurementValuesForWoundMeasurement:woundMeasurement];
        }
        if (0 == [woundMeasurementValues count]) {
            continue;
        }
        // else add the wound measurement title (section)
        string = woundMeasurement.title;
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        // add value title : value - unit
        NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:1];
        NSMutableDictionary *valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:0];
        // now draw title/label : value (unit)
        NSInteger index = 1;
        for (WMWoundMeasurementValue *woundMeasurementValue in woundMeasurementValues) {
            NSString *unit = woundMeasurementValue.woundMeasurement.unit;
            NSString *title = nil;
            if ([woundMeasurementValue respondsToSelector:@selector(labelText)]) {
                title = [woundMeasurementValue performSelector:@selector(labelText)];
            } else {
                title = woundMeasurementValue.woundMeasurement.title;
            }
            NSString *value = woundMeasurementValue.displayValue;
            BOOL keyHasValue = [value length] > 0;
            attributedString = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            if (keyHasValue && ![title isEqualToString:value]) {
                string = [NSString stringWithFormat:@": %@", value];
                if ([unit length] > 0) {
                    string = [string stringByAppendingFormat:@" (%@)", unit];
                }
                attributedString = [[NSAttributedString alloc] initWithString:string attributes:valueAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
            }
            if (index < [woundMeasurementValues count]) {
                // new paragraph
                [mutableAttributedString appendAttributedString:paragraphAttributedString];
            }
            ++index;
        }
    }
    return mutableAttributedString;
}

@end

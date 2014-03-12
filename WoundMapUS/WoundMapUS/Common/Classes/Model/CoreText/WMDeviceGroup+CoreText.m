//
//  WMDeviceGroup+CoreText.m
//  WoundMAP
//
//  Created by Todd Guion on 12/23/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMDeviceGroup+CoreText.h"
#import "WMDeviceGroup.h"
#import "WCDeviceCategory.h"
#import "WCDevice.h"
#import "WCDeviceValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMDeviceGroup (CoreText)

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = @"Risk Assessment - Devices";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    // date modified
    string = [NSDateFormatter localizedStringFromDate:self.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    if (self.isClosed) {
        string = [string stringByAppendingString:@" (closed)"];
    }
    currentFontSize = fontSize - 2.0;
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // now iterate through all devices
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    NSArray *deviceValues = self.sortedDeviceValues;
    WCDeviceCategory *deviceCategory = nil;
    for (WCDeviceValue *deviceValue in deviceValues) {
        if (![deviceValue.device.category isEqual:deviceCategory]) {
            deviceCategory = deviceValue.device.category;
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            // draw category
            string = deviceCategory.title;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        NSString *valueString = deviceValue.device.title;
        NSMutableDictionary *valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:1];
        if ([deviceValue.value length] > 0) {
            NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:1];
            attributedString = [[NSAttributedString alloc] initWithString:[string stringByAppendingString:@": "] attributes:titleAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:0];
            attributedString = [[NSAttributedString alloc] initWithString:deviceValue.value attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        } else {
            attributedString = [[NSAttributedString alloc] initWithString:valueString attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
    }
    return mutableAttributedString;
}

@end

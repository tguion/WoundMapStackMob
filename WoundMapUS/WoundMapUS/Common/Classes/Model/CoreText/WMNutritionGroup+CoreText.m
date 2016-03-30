//
//  WMNutritionGroup+CoreText.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/20/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMNutritionGroup+CoreText.h"
#import "WMNutritionGroup.h"
#import "WMNutritionItem.h"
#import "WMNutritionValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMNutritionGroup (CoreText)

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = @"Risk Assessment - Nutrition";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    // date modified
    string = [NSDateFormatter localizedStringFromDate:self.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    if (self.closedFlagValue) {
        string = [string stringByAppendingString:@" (closed)"];
    }
    currentFontSize = fontSize - 2.0;
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // now iterate through all medications
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    NSArray *nutritionValues = self.sortedValues;
    NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:1];
    for (WMNutritionValue *value in nutritionValues) {
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        // item
        string = [NSString stringWithFormat:@"%@: ", value.item.title];
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // value
        attributedString = [[NSAttributedString alloc] initWithString:value.value attributes:titleAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
    }
    return mutableAttributedString;
}

@end

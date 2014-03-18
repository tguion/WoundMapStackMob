//
//  WMSkinAssessmentGroup+CoreText.m
//  WoundMAP
//
//  Created by Todd Guion on 12/24/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSkinAssessmentGroup+CoreText.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentCategory.h"
#import "WMSkinAssessment.h"
#import "WMSkinAssessmentValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMSkinAssessmentGroup (CoreText)

#pragma mark - WCCoreTextDataSource

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = @"Skin Assessment";
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
    // now iterate through all values
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    NSArray *skinAssessmentValues = self.sortedSkinAssessmentValues;
    WMSkinAssessmentCategory *skinAssessmentCategory = nil;
    for (WMSkinAssessmentValue *skinAssessmentValue in skinAssessmentValues) {
        if (![skinAssessmentValue.skinAssessment.category isEqual:skinAssessmentCategory]) {
            skinAssessmentCategory = skinAssessmentValue.skinAssessment.category;
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            // draw category
            string = skinAssessmentCategory.title;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        NSString *valueString = skinAssessmentValue.skinAssessment.title;
        NSMutableDictionary *valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:1];
        if ([skinAssessmentValue.value length] > 0) {
            NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:1];
            attributedString = [[NSAttributedString alloc] initWithString:[string stringByAppendingString:@": "] attributes:titleAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:0];
            attributedString = [[NSAttributedString alloc] initWithString:skinAssessmentValue.value attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        } else {
            attributedString = [[NSAttributedString alloc] initWithString:valueString attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
    }
    return mutableAttributedString;
}

@end

//
//  WMMedicationGroup+CoreText.m
//  WoundMAP
//
//  Created by Todd Guion on 12/23/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMMedicationGroup+CoreText.h"
#import "WMMedicationGroup.h"
#import "WMMedicationCategory.h"
#import "WMMedication.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMMedicationGroup (CoreText)

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = @"Risk Assessment - Medications";
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
    // now iterate through all medications
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    WMMedicationCategory *currentMedicationCategory = nil;
    NSArray *medications = self.sortedMedications;
    NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:1];
    for (WMMedication *medication in medications) {
        if (![medication.category isEqual:currentMedicationCategory]) {
            // category changed - draw it
            currentMedicationCategory = medication.category;
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            // draw category
            string = currentMedicationCategory.title;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        // draw medication
        attributedString = [[NSAttributedString alloc] initWithString:medication.title attributes:titleAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
    }
    return mutableAttributedString;
}

@end

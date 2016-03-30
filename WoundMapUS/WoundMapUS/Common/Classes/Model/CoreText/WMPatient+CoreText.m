//
//  WMPatient+CoreText.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMPatient+CoreText.h"
#import "WMMedicalHistoryGroup.h"
#import "WMMedicalHistoryItem.h"
#import "WMMedicalHistoryValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMPatient (CoreText)

#pragma mark - WCCoreTextDataSource

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // Medical History
    NSString *string = @"Medical History";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    NSString *key = nil;
    NSString *value = nil;
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    // medical history
    WMMedicalHistoryGroup *medicalHistoryGroup = self.lastActiveMedicalHistoryGroup;
    if (medicalHistoryGroup) {
        NSArray *medicalHistoryValues = [WMMedicalHistoryValue MR_findAllSortedBy:[NSString stringWithFormat:@"%@.%@", WMMedicalHistoryValueRelationships.medicalHistoryItem, WMMedicalHistoryItemAttributes.sortRank]
                                                                        ascending:YES
                                                                    withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMMedicalHistoryValueRelationships.medicalHistoryGroup, medicalHistoryGroup]
                                                                        inContext:managedObjectContext];
        for (WMMedicalHistoryValue *medicalHistoryValue in medicalHistoryValues) {
            key = medicalHistoryValue.medicalHistoryItem.title;
            if (nil == key) {
                NSAssert(false, @"item is nil for WMMedicalHistoryValue %@", medicalHistoryValue);
                continue;
            }
            switch (medicalHistoryValue.medicalHistoryItem.valueTypeCodeValue) {
                case GroupValueTypeCodeNoImageInlineSwitch: {
                    value = [medicalHistoryValue.value boolValue] ? @"Yes":@"No";
                    break;
                }
                case GroupValueTypeCodeNavigateToNote: {
                    value = medicalHistoryValue.value;
                    break;
                }
            }
            string = [key stringByAppendingFormat:@": %@", value];
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
        }
    }
    // Surgical History
    string = @"Surgical History";
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    string = self.surgicalHistory;
    if ([string length]) {
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
    }
    // Surgical History
    string = @"Relavent Medications";
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    string = self.relevantMedications;
    if ([string length]) {
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
    }
    return mutableAttributedString;
}

@end

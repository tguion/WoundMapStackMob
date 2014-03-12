//
//  WMPsychoSocialGroup+CoreText.m
//  WoundMAP
//
//  Created by Todd Guion on 12/23/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMPsychoSocialGroup+CoreText.h"
#import "WMPsychoSocialGroup.h"
#import "WCPsychoSocialItem.h"
#import "WCPsychoSocialValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMPsychoSocialGroup (CoreText)

#pragma mark - WCCoreTextDataSource

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = @"PsychoSocial";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    // date modified
    string = [NSDateFormatter localizedStringFromDate:self.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    currentFontSize = fontSize - 2.0;
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // now iterate through all items
    NSMutableDictionary *subheadingAttributes = [modelTextKitAtrributes subheadingAttributesForFontSize:currentFontSize];
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    NSArray *psychoSocialItems = [WCPsychoSocialItem sortedPsychoSocialItemsForParentItem:nil managedObjectContext:managedObjectContext persistentStore:nil];
    NSString *sectionTitle = nil;
    for (WCPsychoSocialItem *psychoSocialItem in psychoSocialItems) {
        if (![psychoSocialItem.sectionTitle isEqual:sectionTitle]) {
            sectionTitle = psychoSocialItem.sectionTitle;
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            string = sectionTitle;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:subheadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
        // get values for current item
        NSArray *psychoSocialValues = [WMPsychoSocialGroup sortedPsychoSocialValuesForGroup:self psychoSocialItem:psychoSocialItem];
        if (0 == [psychoSocialValues count]) {
            // check if any values down this tree
            if (![WMPsychoSocialGroup hasPsychoSocialValueForChildrenOfParentItem:self
                                                           parentPsychoSocialItem:psychoSocialItem
                                                             managedObjectContext:managedObjectContext]) {
                continue;
            }
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            string = psychoSocialItem.title;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            // continue with children
            [self appendToMutableAttributedString:mutableAttributedString
                        forParentPsychoSocialItem:psychoSocialItem
                                      indentLevel:1
                                 withBaseFontSize:currentFontSize];
            continue;
        }
        // new paragraph and draw item title
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        string = psychoSocialItem.title;
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // else draw values for current item
        [self appendValuesToMutableAttributedString:mutableAttributedString
                                             values:psychoSocialValues
                                        indentLevel:1
                                   withBaseFontSize:currentFontSize];
    }
    return mutableAttributedString;
}

#pragma mark - Core

- (void)appendValuesToMutableAttributedString:(NSMutableAttributedString *)mutableAttributedString
                                       values:(NSArray *)psychoSocialValues
                                  indentLevel:(NSUInteger)indentLevel
                             withBaseFontSize:(CGFloat)currentFontSize
{
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    NSAttributedString *attributedString = nil;
    NSMutableDictionary *valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:indentLevel];
    for (WCPsychoSocialValue *psychoSocialValue in psychoSocialValues) {
        NSString *string = psychoSocialValue.title;
        if ([string isEqualToString:psychoSocialValue.psychoSocialItem.title] && [psychoSocialValue.value length] == 0) {
            // already drawn
            continue;
        }
        // else new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        if ([psychoSocialValue.value length] > 0) {
            if (![psychoSocialValue.title isEqualToString:psychoSocialValue.psychoSocialItem.title]) {
                NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:indentLevel];
                attributedString = [[NSAttributedString alloc] initWithString:[string stringByAppendingString:@": "] attributes:titleAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
                valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:0];
                attributedString = [[NSAttributedString alloc] initWithString:psychoSocialValue.displayValue attributes:valueAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
            } else {
                valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:indentLevel];
                attributedString = [[NSAttributedString alloc] initWithString:psychoSocialValue.displayValue attributes:valueAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
            }
        } else {
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
    }
}

- (void)appendToMutableAttributedString:(NSMutableAttributedString *)mutableAttributedString
              forParentPsychoSocialItem:(WCPsychoSocialItem *)psychoSocialItem
                            indentLevel:(NSUInteger)indentLevel
                       withBaseFontSize:(CGFloat)currentFontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSString *string = nil;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    NSAttributedString *attributedString = nil;
    NSMutableDictionary *valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:indentLevel];
    // get all values instance for woundTreatment
    NSArray *subitems = [WCPsychoSocialItem sortedPsychoSocialItemsForParentItem:psychoSocialItem
                                                                  managedObjectContext:managedObjectContext
                                                                       persistentStore:nil];
    for (WCPsychoSocialItem *subitem in subitems) {
        NSArray *psychoSocialValues = [WMPsychoSocialGroup sortedPsychoSocialValuesForGroup:self psychoSocialItem:subitem];
        if (0 == [psychoSocialValues count]) {
            // check if any values down this tree
            if (![WMPsychoSocialGroup hasPsychoSocialValueForChildrenOfParentItem:self
                                                           parentPsychoSocialItem:subitem
                                                             managedObjectContext:managedObjectContext]) {
                continue;
            }
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            string = subitem.title;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            // continue with children
            [self appendToMutableAttributedString:mutableAttributedString
                        forParentPsychoSocialItem:subitem
                                      indentLevel:(indentLevel + 1)
                                 withBaseFontSize:currentFontSize];
            continue;
        }
        // new paragraph and draw item title
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        string = subitem.title;
        if ([subitem.parentItem.subitemPrompt length] > 0) {
            string = [NSString stringWithFormat:@"%@: %@", subitem.parentItem.subitemPrompt, string];
        }
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:valueAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // else draw values for current item
        [self appendValuesToMutableAttributedString:mutableAttributedString
                                             values:psychoSocialValues
                                        indentLevel:(indentLevel + 1)
                                   withBaseFontSize:currentFontSize];
    }
}

@end

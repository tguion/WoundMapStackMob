//
//  WMWoundTreatmentGroup+CoreText.m
//  WoundMAP
//
//  Created by Todd Guion on 12/23/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundTreatmentGroup+CoreText.h"
#import "WMWound.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatment.h"
#import "WMWoundTreatmentValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMWoundTreatmentGroup (CoreText)

#pragma mark - WCCoreTextDataSource

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = [@"Wound Treatment for " stringByAppendingString:self.wound.shortName];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    // date modified
    string = [NSDateFormatter localizedStringFromDate:self.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    currentFontSize = fontSize - 2.0;
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // now iterate through all treatments
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    NSArray *sortedRootWoundTreatments = [WMWoundTreatment sortedRootWoundTreatments:managedObjectContext];
    for (WMWoundTreatment *rootWoundTreatment in sortedRootWoundTreatments) {
        if (![self hasWoundTreatmentValuesForWoundTreatmentAndChildren:rootWoundTreatment]) {
            continue;
        }
        // else draw section title
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        // draw title
        string = rootWoundTreatment.title;
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // now append to mutable attributed string for children of rootWoundTreatment
        [self appendToMutableAttributedString:mutableAttributedString
                      forParentWoundTreatment:rootWoundTreatment
                                  indentLevel:1
                             withBaseFontSize:currentFontSize];
    }
    return mutableAttributedString;
}

#pragma mark - Core

- (void)appendToMutableAttributedString:(NSMutableAttributedString *)mutableAttributedString
                forParentWoundTreatment:(WMWoundTreatment *)woundTreatment
                            indentLevel:(NSUInteger)indentLevel
                       withBaseFontSize:(CGFloat)currentFontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSString *string = nil;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    NSAttributedString *attributedString = nil;
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:indentLevel];
    // get all WCWoundTreatmentValues instance for woundTreatment
    NSArray *sortedChildrenWoundTreatments = woundTreatment.sortedChildrenWoundTreatments;
    WMWoundTreatmentValue *woundTreatmentValue = nil;
    NSString *sectionTitle = nil;
    BOOL sectionTitleFound = NO;
    for (WMWoundTreatment *childWoundTreatment in sortedChildrenWoundTreatments) {
        if (![self hasWoundTreatmentValuesForWoundTreatmentAndChildren:childWoundTreatment]) {
            continue;
        }
        // check if have sections
        if (!sectionTitleFound && nil != childWoundTreatment.sectionTitle) {
            sectionTitleFound = YES;
            ++indentLevel;
        }
        // check if changing sections
        if (nil != childWoundTreatment.sectionTitle && ![childWoundTreatment.sectionTitle isEqualToString:sectionTitle]) {
            // draw a section
            sectionTitle = childWoundTreatment.sectionTitle;
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            // draw category
            string = sectionTitle;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
        // else childWoundTreatment or a child of childWoundTreatment has a value
        woundTreatmentValue = [self woundTreatmentValueForWoundTreatment:childWoundTreatment
                                                                  create:NO
                                                                   value:nil
                                                    managedObjectContext:managedObjectContext];
        if (nil == woundTreatmentValue) {
            // draw heading
            string = childWoundTreatment.title;
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            // continue with children
            [self appendToMutableAttributedString:mutableAttributedString
                          forParentWoundTreatment:childWoundTreatment
                                      indentLevel:(indentLevel + 1)
                                 withBaseFontSize:currentFontSize];
            continue;
        }
        // else we have data for childWoundTreatment - print the child title and value
        string = childWoundTreatment.title;
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        NSMutableDictionary *valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:indentLevel];
        if ([woundTreatmentValue.value length] > 0) {
            NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:indentLevel];
            if (childWoundTreatment.combineKeyAndValue) {
                string = [childWoundTreatment combineKeyAndValue:woundTreatmentValue.value];
                attributedString = [[NSAttributedString alloc] initWithString:string attributes:titleAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
            } else {
                attributedString = [[NSAttributedString alloc] initWithString:[string stringByAppendingString:@": "] attributes:titleAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
                valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:0];
                attributedString = [[NSAttributedString alloc] initWithString:woundTreatmentValue.value attributes:valueAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
            }
        } else {
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
    }
}

@end

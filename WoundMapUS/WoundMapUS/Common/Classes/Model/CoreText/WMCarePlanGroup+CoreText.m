//
//  WMCarePlanGroup+CoreText.m
//  WoundMAP
//
//  Created by Todd Guion on 12/21/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCarePlanGroup+CoreText.h"
#import "WMCarePlanGroup.h"
#import "WCCarePlanCategory.h"
#import "WCCarePlanValue.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMCarePlanGroup (CoreText)

#pragma mark - WCCoreTextDataSource

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    CGFloat currentFontSize = fontSize;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    // heading
    NSString *string = @"Care Plan";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // new paragraph
    [mutableAttributedString appendAttributedString:paragraphAttributedString];
    // date modified
    string = [NSDateFormatter localizedStringFromDate:self.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    currentFontSize = fontSize - 2.0;
    attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes headingAttributesForFontSize:currentFontSize]];
    [mutableAttributedString appendAttributedString:attributedString];
    // now iterate through all categories
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:0];
    NSArray *sortedRootCarePlanCategories = [WCCarePlanCategory sortedRootCarePlanCategories:managedObjectContext];
    for (WCCarePlanCategory *rootCarePlanCategory in sortedRootCarePlanCategories) {
        if (![self hasValueForCategoryOrDescendantsPlusItems:rootCarePlanCategory]) {
            continue;
        }
        // else draw title with section attributes
        string = rootCarePlanCategory.title;
        // check for inline replacement
        WCCarePlanValue *carePlanValue = [self carePlanValueForCarePlanCategory:rootCarePlanCategory
                                                                         create:NO
                                                                          value:nil
                                                           managedObjectContext:managedObjectContext];
        if ([carePlanValue.value length] > 0) {
            if (rootCarePlanCategory.combineKeyAndValue) {
                string = [rootCarePlanCategory combineKeyAndValue:carePlanValue.value];
            } else {
                string = [string stringByAppendingFormat:@": %@", carePlanValue.value];
            }
        }
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
        [mutableAttributedString appendAttributedString:attributedString];
        // now append to mutable attributed string for children of rootCarePlanCategory
        [self appendToMutableAttributedString:mutableAttributedString
                    forParentCarePlanCategory:rootCarePlanCategory
                                  indentLevel:1
                             withBaseFontSize:currentFontSize];
    }
    
    return mutableAttributedString;
}

#pragma mark - Core

- (void)appendToMutableAttributedString:(NSMutableAttributedString *)mutableAttributedString
              forParentCarePlanCategory:(WCCarePlanCategory *)parentCarePlanCategory
                            indentLevel:(NSUInteger)indentLevel
                       withBaseFontSize:(CGFloat)currentFontSize
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSString *string = nil;
    NSAttributedString *paragraphAttributedString = [modelTextKitAtrributes paragraphAttributedString];
    NSAttributedString *attributedString = nil;
    NSMutableDictionary *sectionHeadingAttributes = [modelTextKitAtrributes sectionHeadingAttributesForFontSize:currentFontSize indentLevel:indentLevel];
    //  draw for each subcategory
    NSArray *sortedSubcategoriesCategories = parentCarePlanCategory.sortedChildernCarePlanCategories;
    if ([sortedSubcategoriesCategories count] == 0) {
        return;
    }
    // else handle headIndent
    WCCarePlanValue *carePlanValue = nil;
    for (WCCarePlanCategory *subcategory in sortedSubcategoriesCategories) {
        // subcategory or a child of subcategory has a value
        carePlanValue = [self carePlanValueForCarePlanCategory:subcategory
                                                        create:NO
                                                         value:nil
                                          managedObjectContext:managedObjectContext];
        if (nil == carePlanValue) {
            // check if there is any data down this path
            if (![self hasValueForCategoryOrDescendantsPlusItems:subcategory]) {
                // dead end, bail
                continue;
            }
            // new paragraph
            if (![mutableAttributedString.string hasSuffix:@"\n"]) {
                [mutableAttributedString appendAttributedString:paragraphAttributedString];
            }
            // else there's still data down there somewhere - draw heading
            string = subcategory.title;
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:sectionHeadingAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
            // new paragraph
            [mutableAttributedString appendAttributedString:paragraphAttributedString];
            // continue with subcategories
            [self appendToMutableAttributedString:mutableAttributedString
                        forParentCarePlanCategory:subcategory
                                      indentLevel:(indentLevel + 1)
                                 withBaseFontSize:currentFontSize];
            continue;
        }
        // else we have data for subcategory - print the child title and value - indent further
        string = subcategory.title;
        NSMutableDictionary *valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:indentLevel];
        if ([carePlanValue.value length] > 0) {
            NSMutableDictionary *titleAttributes = [modelTextKitAtrributes valueTitleAttributesForFontSize:currentFontSize indentLevel:indentLevel];
            if (subcategory.combineKeyAndValue) {
                string = [subcategory combineKeyAndValue:carePlanValue.value];
                attributedString = [[NSAttributedString alloc] initWithString:string attributes:titleAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
            } else {
                attributedString = [[NSAttributedString alloc] initWithString:[string stringByAppendingString:@": "] attributes:titleAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
                valueAttributes = [modelTextKitAtrributes valueAttributesForFontSize:currentFontSize indentLevel:0];
                attributedString = [[NSAttributedString alloc] initWithString:carePlanValue.value attributes:valueAttributes];
                [mutableAttributedString appendAttributedString:attributedString];
            }
        } else {
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:valueAttributes];
            [mutableAttributedString appendAttributedString:attributedString];
        }
        // new paragraph
        [mutableAttributedString appendAttributedString:paragraphAttributedString];
    }
}

@end

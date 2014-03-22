//
//  WMMedicationGroupTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMMedicationGroupTableViewCell.h"
#import "WMMedicationGroup.h"
#import "WMInterventionStatus.h"

@interface WMMedicationGroupTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMMedicationGroupTableViewCell

@synthesize medicationGroup=_medicationGroup;
@dynamic isHighlightedOrSelected;

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *MedicationGroupTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        MedicationGroupTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                          [UIColor blackColor], NSForegroundColorAttributeName,
                                          paragraphStyle, NSParagraphStyleAttributeName,
                                          nil];
    });
    return MedicationGroupTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *MedicationGroupTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        MedicationGroupTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                  [UIColor blackColor], NSForegroundColorAttributeName,
                                                  paragraphStyle, NSParagraphStyleAttributeName,
                                                  nil];
    });
    return MedicationGroupTitleSelectedAttributes;
}

+ (NSDictionary *)valueAttributes
{
    static NSDictionary *MedicationGroupValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        MedicationGroupValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                          [UIColor blackColor], NSForegroundColorAttributeName,
                                          paragraphStyle, NSParagraphStyleAttributeName,
                                          nil];
    });
    return MedicationGroupValueAttributes;
}

+ (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *MedicationGroupValueSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        MedicationGroupValueSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                  [UIColor blackColor], NSForegroundColorAttributeName,
                                                  paragraphStyle, NSParagraphStyleAttributeName,
                                                  nil];
    });
    return MedicationGroupValueSelectedAttributes;
}

- (void)setMedicationGroup:(WMMedicationGroup *)medicationGroup
{
    if (_medicationGroup == medicationGroup) {
        return;
    }
    // else
    _medicationGroup = medicationGroup;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    // set our reference to document
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    // draw status title
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMMedicationGroupTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMMedicationGroupTableViewCell titleAttributes];
    }
    NSString *string = self.medicationGroup.status.title;
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    // draw date modified
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMMedicationGroupTableViewCell valueSelectedAttributes];
    } else {
        textAttributes = [WMMedicationGroupTableViewCell valueAttributes];
    }
    string = [NSDateFormatter localizedStringFromDate:self.medicationGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    aSize = [string sizeWithAttributes:textAttributes];
    x = (width - aSize.width - 8.0);
    y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
}

@end

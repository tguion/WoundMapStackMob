//
//  WMWoundTreatmentGroupTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundTreatmentGroupTableViewCell.h"
#import "WMWoundTreatmentGroup.h"
#import "WMInterventionStatus.h"

@interface WMWoundTreatmentGroupTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMWoundTreatmentGroupTableViewCell

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *WoundTreatmentGroupTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        WoundTreatmentGroupTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                [UIColor blackColor], NSForegroundColorAttributeName,
                                                paragraphStyle, NSParagraphStyleAttributeName,
                                                nil];
    });
    return WoundTreatmentGroupTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *WoundTreatmentGroupTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        WoundTreatmentGroupTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                        [UIColor blackColor], NSForegroundColorAttributeName,
                                                        paragraphStyle, NSParagraphStyleAttributeName,
                                                        nil];
    });
    return WoundTreatmentGroupTitleSelectedAttributes;
}

+ (NSDictionary *)valueAttributes
{
    static NSDictionary *WoundTreatmentGroupValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        WoundTreatmentGroupValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                [UIColor blackColor], NSForegroundColorAttributeName,
                                                paragraphStyle, NSParagraphStyleAttributeName,
                                                nil];
    });
    return WoundTreatmentGroupValueAttributes;
}

+ (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *WoundTreatmentGroupValueSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        WoundTreatmentGroupValueSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                        [UIColor blackColor], NSForegroundColorAttributeName,
                                                        paragraphStyle, NSParagraphStyleAttributeName,
                                                        nil];
    });
    return WoundTreatmentGroupValueSelectedAttributes;
}

- (void)setWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
{
    if (_woundTreatmentGroup == woundTreatmentGroup) {
        return;
    }
    // else
    [self willChangeValueForKey:@"woundTreatmentGroup"];
    _woundTreatmentGroup = woundTreatmentGroup;
    [self didChangeValueForKey:@"woundTreatmentGroup"];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    // set our reference to document
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat height = CGRectGetHeight(rect);
    // draw status title
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMWoundTreatmentGroupTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMWoundTreatmentGroupTableViewCell titleAttributes];
    }
    NSString *string = self.woundTreatmentGroup.status.title;
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    // draw date modified
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMWoundTreatmentGroupTableViewCell valueSelectedAttributes];
    } else {
        textAttributes = [WMWoundTreatmentGroupTableViewCell valueAttributes];
    }
    string = [NSDateFormatter localizedStringFromDate:self.woundTreatmentGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    aSize = [string sizeWithAttributes:textAttributes];
    x = (maxX - aSize.width);
    y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
}

@end

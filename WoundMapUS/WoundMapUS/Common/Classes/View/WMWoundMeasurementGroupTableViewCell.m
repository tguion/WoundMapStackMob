//
//  WMWoundMeasurementGroupTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundMeasurementGroupTableViewCell.h"
#import "WMWoundMeasurementGroup.h"
#import "WMInterventionStatus.h"

@interface WMWoundMeasurementGroupTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMWoundMeasurementGroupTableViewCell

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *WoundMeasurementGroupTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        WoundMeasurementGroupTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return WoundMeasurementGroupTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *WoundMeasurementGroupTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        WoundMeasurementGroupTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                                    paragraphStyle, NSParagraphStyleAttributeName,
                                                    nil];
    });
    return WoundMeasurementGroupTitleSelectedAttributes;
}

+ (NSDictionary *)valueAttributes
{
    static NSDictionary *WoundMeasurementGroupValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        WoundMeasurementGroupValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return WoundMeasurementGroupValueAttributes;
}

+ (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *WoundMeasurementGroupValueSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        WoundMeasurementGroupValueSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                                    paragraphStyle, NSParagraphStyleAttributeName,
                                                    nil];
    });
    return WoundMeasurementGroupValueSelectedAttributes;
}

- (void)setWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup
{
    if (_woundMeasurementGroup == woundMeasurementGroup) {
        return;
    }
    // else
    [self willChangeValueForKey:@"woundMeasurementGroup"];
    _woundMeasurementGroup = woundMeasurementGroup;
    [self didChangeValueForKey:@"woundMeasurementGroup"];
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
        textAttributes = [WMWoundMeasurementGroupTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMWoundMeasurementGroupTableViewCell titleAttributes];
    }
    NSString *string = self.woundMeasurementGroup.status.title;
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    // draw date modified
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMWoundMeasurementGroupTableViewCell valueSelectedAttributes];
    } else {
        textAttributes = [WMWoundMeasurementGroupTableViewCell valueAttributes];
    }
    string = [NSDateFormatter localizedStringFromDate:self.woundMeasurementGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    aSize = [string sizeWithAttributes:textAttributes];
    x = (maxX - aSize.width);
    y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
}

@end

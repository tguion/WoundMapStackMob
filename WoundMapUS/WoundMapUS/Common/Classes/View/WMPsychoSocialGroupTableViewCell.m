//
//  WMPsychoSocialGroupTableViewCell.m
//  WoundMAP
//
//  Created by Todd Guion on 12/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMPsychoSocialGroupTableViewCell.h"
#import "WMPsychoSocialGroup.h"
#import "WMInterventionStatus.h"

@interface WMPsychoSocialGroupTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMPsychoSocialGroupTableViewCell

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *PsychoSocialGroupTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        PsychoSocialGroupTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                              [UIColor blackColor], NSForegroundColorAttributeName,
                                              paragraphStyle, NSParagraphStyleAttributeName,
                                              nil];
    });
    return PsychoSocialGroupTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *PsychoSocialGroupTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        PsychoSocialGroupTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                      [UIColor blackColor], NSForegroundColorAttributeName,
                                                      paragraphStyle, NSParagraphStyleAttributeName,
                                                      nil];
    });
    return PsychoSocialGroupTitleSelectedAttributes;
}

+ (NSDictionary *)valueAttributes
{
    static NSDictionary *PsychoSocialGroupValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PsychoSocialGroupValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                              [UIColor blackColor], NSForegroundColorAttributeName,
                                              paragraphStyle, NSParagraphStyleAttributeName,
                                              nil];
    });
    return PsychoSocialGroupValueAttributes;
}

+ (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *PsychoSocialGroupValueSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PsychoSocialGroupValueSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                      [UIColor blackColor], NSForegroundColorAttributeName,
                                                      paragraphStyle, NSParagraphStyleAttributeName,
                                                      nil];
    });
    return PsychoSocialGroupValueSelectedAttributes;
}

- (void)setPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
{
    if (_psychoSocialGroup == psychoSocialGroup) {
        return;
    }
    // else
    [self willChangeValueForKey:@"psychoSocialGroup"];
    _psychoSocialGroup = psychoSocialGroup;
    [self didChangeValueForKey:@"psychoSocialGroup"];
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
    NSString *string = self.psychoSocialGroup.status.title;
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMPsychoSocialGroupTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMPsychoSocialGroupTableViewCell titleAttributes];
    }
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    // draw date modified
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMPsychoSocialGroupTableViewCell valueSelectedAttributes];
    } else {
        textAttributes = [WMPsychoSocialGroupTableViewCell valueAttributes];
    }
    string = [NSDateFormatter localizedStringFromDate:self.psychoSocialGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    aSize = [string sizeWithAttributes:textAttributes];
    x = (maxX - aSize.width);
    y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
}

@end

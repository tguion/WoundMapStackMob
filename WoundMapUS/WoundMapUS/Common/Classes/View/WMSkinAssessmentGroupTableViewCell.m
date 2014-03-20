//
//  WMSkinAssessmentGroupTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSkinAssessmentGroupTableViewCell.h"
#import "WMSkinAssessmentGroup.h"
#import "WMInterventionStatus.h"

@interface WMSkinAssessmentGroupTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMSkinAssessmentGroupTableViewCell

@synthesize skinAssessmentGroup=_skinAssessmentGroup;
@dynamic isHighlightedOrSelected;

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *SkinAssessmentGroupTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        SkinAssessmentGroupTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                          [UIColor blackColor], NSForegroundColorAttributeName,
                                          paragraphStyle, NSParagraphStyleAttributeName,
                                          nil];
    });
    return SkinAssessmentGroupTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *SkinAssessmentGroupTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        SkinAssessmentGroupTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                  [UIColor blackColor], NSForegroundColorAttributeName,
                                                  paragraphStyle, NSParagraphStyleAttributeName,
                                                  nil];
    });
    return SkinAssessmentGroupTitleSelectedAttributes;
}

+ (NSDictionary *)valueAttributes
{
    static NSDictionary *SkinAssessmentGroupValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        SkinAssessmentGroupValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                          [UIColor blackColor], NSForegroundColorAttributeName,
                                          paragraphStyle, NSParagraphStyleAttributeName,
                                          nil];
    });
    return SkinAssessmentGroupValueAttributes;
}

+ (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *SkinAssessmentGroupValueSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        SkinAssessmentGroupValueSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                  [UIColor blackColor], NSForegroundColorAttributeName,
                                                  paragraphStyle, NSParagraphStyleAttributeName,
                                                  nil];
    });
    return SkinAssessmentGroupValueSelectedAttributes;
}

- (void)setSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
{
    if (_skinAssessmentGroup == skinAssessmentGroup) {
        return;
    }
    // else
    [self willChangeValueForKey:@"skinAssessmentGroup"];
    _skinAssessmentGroup = skinAssessmentGroup;
    [self didChangeValueForKey:@"skinAssessmentGroup"];
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
    NSString *string = self.skinAssessmentGroup.status.title;
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMSkinAssessmentGroupTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMSkinAssessmentGroupTableViewCell titleAttributes];
    }
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    // draw date modified
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMSkinAssessmentGroupTableViewCell valueSelectedAttributes];
    } else {
        textAttributes = [WMSkinAssessmentGroupTableViewCell valueAttributes];
    }
    string = [NSDateFormatter localizedStringFromDate:self.skinAssessmentGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    aSize = [string sizeWithAttributes:textAttributes];
    x = (maxX - aSize.width);
    y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
}

@end

//
//  WMNavigationStageTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 7/13/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMNavigationStageTableViewCell.h"
#import "WMNavigationStage.h"

@interface WMNavigationStageTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMNavigationStageTableViewCell

@synthesize navigationStage=_navigationStage;
@dynamic isHighlightedOrSelected;

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *NavigationStageTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        NavigationStageTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                   [UIColor blackColor], NSForegroundColorAttributeName,
                                   paragraphStyle, NSParagraphStyleAttributeName,
                                   nil];
    });
    return NavigationStageTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *NavigationStageTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        NavigationStageTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                           [UIColor blackColor], NSForegroundColorAttributeName,
                                           paragraphStyle, NSParagraphStyleAttributeName,
                                           nil];
    });
    return NavigationStageTitleSelectedAttributes;
}

+ (NSDictionary *)valueAttributes
{
    static NSDictionary *NavigationStageValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NavigationStageValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return NavigationStageValueAttributes;
}

+ (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *NavigationStageValueSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NavigationStageValueSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return NavigationStageValueSelectedAttributes;
}

- (void)setNavigationStage:(WMNavigationStage *)navigationStage
{
    if (_navigationStage == navigationStage) {
        return;
    }
    // else
    [self willChangeValueForKey:@"navigationStage"];
    _navigationStage = navigationStage;
    [self didChangeValueForKey:@"navigationStage"];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

+ (CGFloat)heightTheFitsForStage:(WMNavigationStage *)navigationStage width:(CGFloat)width
{
    CGFloat height = 8.0;
    height += [navigationStage.title sizeWithAttributes:self.titleAttributes].height;
    height += [navigationStage.desc boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:self.valueAttributes
                                                 context:nil].size.height;
    return fmaxf(44.0, ceilf(height));
}

- (void)drawContentView:(CGRect)rect
{
    // move to right of cell.imageView
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat offsetX = CGRectGetMaxX(self.imageView.frame) + 8.0;
    CGFloat deltaX = offsetX - minX;
    rect = CGRectMake(offsetX, minY, width - deltaX - 4.0, height);
    CGFloat x = offsetX;
    CGFloat y = minY + 4.0;
    NSString *string = self.navigationStage.title;
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMNavigationStageTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMNavigationStageTableViewCell titleAttributes];
    }
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    rect.origin.y = y + aSize.height;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMNavigationStageTableViewCell valueSelectedAttributes];
    } else {
        textAttributes = [WMNavigationStageTableViewCell valueAttributes];
    }
    string = self.navigationStage.desc;
    [string drawWithRect:rect
                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
              attributes:textAttributes
                 context:nil];
}

@end

//
//  WMNavigationTrackTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMNavigationTrackTableViewCell.h"
#import "WMNavigationTrack.h"

@interface WMNavigationTrackTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMNavigationTrackTableViewCell

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *NavigationTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        NavigationTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                     [UIColor blackColor], NSForegroundColorAttributeName,
                                     paragraphStyle, NSParagraphStyleAttributeName,
                                     nil];
    });
    return NavigationTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *NavigationTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        NavigationTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                             [UIColor blackColor], NSForegroundColorAttributeName,
                                             paragraphStyle, NSParagraphStyleAttributeName,
                                             nil];
    });
    return NavigationTitleSelectedAttributes;
}

+ (NSDictionary *)descAttributes
{
    static NSDictionary *NavigationDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NavigationDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return NavigationDescAttributes;
}

+ (NSDictionary *)descSelectedAttributes
{
    static NSDictionary *NavigationDescSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSLineBreakByWordWrapping;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NavigationDescSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return NavigationDescSelectedAttributes;
}

- (void)setNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    if (_navigationTrack == navigationTrack) {
        return;
    }
    // else
    [self willChangeValueForKey:@"navigationTrack"];
    _navigationTrack = navigationTrack;
    [self didChangeValueForKey:@"navigationTrack"];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

+ (CGFloat)heightTheFitsForTrack:(WMNavigationTrack *)navigationTrack width:(CGFloat)width
{
    CGFloat height = 8.0;
    height += [navigationTrack.title sizeWithAttributes:[self titleAttributes]].height;
    height += ceilf([navigationTrack.desc boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                     attributes:[self descAttributes]
                                                        context:nil].size.height);
    return fmaxf(44.0, height);
}

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMNavigationTrackTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMNavigationTrackTableViewCell titleAttributes];
    }
    // move to right of cell.imageView
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat minX = fmaxf(CGRectGetMaxX(self.imageView.frame) + 8.0, CGRectGetMinX(rect));
    CGFloat minY = CGRectGetMinY(rect);
    rect = CGRectMake(minX, minY, width - 4.0, height);
    CGFloat x = minX;
    CGFloat y = minY + 4.0;
    NSString *string = self.navigationTrack.title;
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    rect.origin.y += aSize.height + 4.0;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMNavigationTrackTableViewCell descSelectedAttributes];
    } else {
        textAttributes = [WMNavigationTrackTableViewCell descAttributes];
    }
    string = self.navigationTrack.desc;
    [string drawInRect:rect withAttributes:textAttributes];
}

@end

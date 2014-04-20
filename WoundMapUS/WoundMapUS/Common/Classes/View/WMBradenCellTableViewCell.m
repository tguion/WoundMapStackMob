//  WMBradenCellTableViewCell.m
//  WoundCare
//
//  Created by Todd Guion on 8/3/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//
//  TODO: handle low memory and document close/delete: see WMWoundPhotoCollectionViewCell

#import "WMBradenCellTableViewCell.h"
#import "WMBradenSection.h"
#import "WMBradenCare.h"
#import "WCAppDelegate.h"

#define OR_STRING @" OR "

@interface WMBradenCellTableViewCell()

@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (weak, nonatomic) UIButton *button;

@end

@implementation WMBradenCellTableViewCell

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *BradenCellTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        BradenCellTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                     [UIColor blackColor], NSForegroundColorAttributeName,
                                     paragraphStyle, NSParagraphStyleAttributeName,
                                     nil];
    });
    return BradenCellTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *BradenCellTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        BradenCellTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                             [UIColor blackColor], NSForegroundColorAttributeName,
                                             paragraphStyle, NSParagraphStyleAttributeName,
                                             nil];
    });
    return BradenCellTitleSelectedAttributes;
}

+ (NSDictionary *)descAttributes
{
    static NSDictionary *BradenCellDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        BradenCellDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor darkGrayColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return BradenCellDescAttributes;
}

+ (NSDictionary *)descSelectedAttributes
{
    static NSDictionary *BradenCellDescSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSLineBreakByWordWrapping;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        BradenCellDescSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return BradenCellDescSelectedAttributes;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIButton *)button
{
    return (UIButton *)[self.customContentView viewWithTag:1000];
}

- (void)setExpandedFlag:(BOOL)expandedFlag
{
    _expandedFlag = expandedFlag;
    [self.button setImage:[UIImage imageNamed:(self.expandedFlag ? @"ui_up":@"ui_down")] forState:UIControlStateNormal];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (nil != self) {
        // add the button
        UIButton *aButton = [[UIButton alloc] initWithFrame:CGRectMake(8.0, 4.0, 40.0, 40.0)];
        aButton.tag = 1000;
        aButton.opaque = YES;
        [aButton addTarget:self action:@selector(expandedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [aButton setImage:[UIImage imageNamed:(self.expandedFlag ? @"ui_up":@"ui_down")] forState:UIControlStateNormal];
        [self.customContentView addSubview:aButton];
        self.button = aButton;
    }
    return self;
}

- (IBAction)expandedButtonAction:(id)sender
{
    self.expandedFlag = !self.expandedFlag;
    [self.button setImage:[UIImage imageNamed:(self.expandedFlag ? @"ui_up":@"ui_down")] forState:UIControlStateNormal];
    [self.delegate updateExpandedMapForBradenSection:self.bradenSection expanded:self.expandedFlag];
    [self setNeedsLayout];
}

- (void)setBradenSection:(WMBradenSection *)bradenSection
{
	if (_bradenSection == bradenSection) {
		return;
	}
	// else
	[self willChangeValueForKey:@"bradenSection"];
	_bradenSection = bradenSection;
	[self didChangeValueForKey:@"bradenSection"];
	[self setNeedsDisplay];
}

+ (CGFloat)recommendedHeightForBradenSection:(WMBradenSection *)bradenSection expanded:(BOOL)expanded forWidth:(CGFloat)width
{
    width -= 44.0;  // account for accessoryType
    CGFloat height = 44.0;
    if (expanded) {
        UIImage *image = [UIImage imageNamed:@"app-icon-default.png"];
        CGFloat x = 8.0 + image.size.width + 8.0;
        CGFloat y = 0.0;
        CGFloat availableWidth = width - x - 8.0;
        y = (44.0 - image.size.height)/2.0;
        NSString *string = bradenSection.title;
        CGSize aSize = [string sizeWithAttributes:[self titleAttributes]];
        y += aSize.height;
        string = bradenSection.desc;
        aSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
        CGRect boundingRect = [string boundingRectWithSize:aSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:[self descAttributes]
                                                   context:nil];
        aSize = boundingRect.size;
        y += aSize.height;
        if (bradenSection.isScoredCalculated) {
            y += 8.0;
            WMBradenCare *bradenCare = [WMBradenCare bradenCareForSectionTitle:bradenSection.title
                                                                         score:@(bradenSection.score)
                                                          managedObjectContext:[bradenSection managedObjectContext]];
            string = bradenCare.desc;
            aSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
            CGRect boundingRect = [string boundingRectWithSize:aSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:[self descAttributes]
                                                       context:nil];
            aSize = boundingRect.size;
            y += aSize.height;
        }
        y += 19.0;
        height = y;
    }
    return height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.button.frame = CGRectMake(8.0, 4.0, 40.0, 40.0);
}

- (void)drawContentView:(CGRect)rect
{
	CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
	CGFloat x = 8.0;
	CGFloat y = 0.0;
    // determine size of button
    CGFloat buttonMaxX = CGRectGetMaxX(self.button.frame);
    CGFloat buttonHeight = CGRectGetHeight(self.button.frame);
    // draw as though cell height is 44.0
    y = (44.0 - buttonHeight)/2.0;
	// draw title
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMBradenCellTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMBradenCellTableViewCell titleAttributes];
    }
    x += (buttonMaxX + 8.0);
    CGFloat availableWidth = width - x - 8.0;
    NSString *string = nil;
    if (self.bradenSection.isScoredCalculated) {
        string = [NSString stringWithFormat:@"%@ (%ld)", self.bradenSection.title, (long)self.bradenSection.score];
    } else {
        string = self.bradenSection.title;
    }
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    if (!self.expandedFlag) {
        // center the title
        y = (height - aSize.height)/2.0;
    }
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    // draw score if not expanded, otherwise must draw desc, and then if scored, draw care
    if (self.expandedFlag) {
		CGContextRef context = UIGraphicsGetCurrentContext();
        // draw desc
        if (self.isHighlightedOrSelected) {
            textAttributes = [WMBradenCellTableViewCell descSelectedAttributes];
        } else {
            textAttributes = [WMBradenCellTableViewCell descAttributes];
        }
        string = self.bradenSection.desc;
        y += aSize.height;
        aSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
        CGRect boundingRect = [string boundingRectWithSize:aSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:textAttributes
                                                   context:nil];
        boundingRect.origin.x = x;
        boundingRect.origin.y = y;
        aSize = boundingRect.size;
        [string drawInRect:boundingRect withAttributes:textAttributes];
        // draw care
        if (self.bradenSection.isScoredCalculated) {
            CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
            y += aSize.height + 3.5;
            CGContextMoveToPoint(context, x, y);
            CGContextAddLineToPoint(context, x + availableWidth, y);
            CGContextStrokePath(context);
            y += 3.5;
            WMBradenCare *bradenCare = [WMBradenCare bradenCareForSectionTitle:self.bradenSection.title
                                                                         score:@(self.bradenSection.score)
                                                          managedObjectContext:[self.bradenSection managedObjectContext]];
            string = bradenCare.desc;
            aSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
            CGRect boundingRect = [string boundingRectWithSize:aSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:textAttributes
                                                       context:nil];
            boundingRect.origin.x = x;
            boundingRect.origin.y = y;
            [string drawInRect:boundingRect withAttributes:textAttributes];
        }
    }
}


@end

//
//  WMDevicesGroupTableViewCell.m
//  WoundMAP
//
//  Created by Todd Guion on 12/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMDevicesGroupTableViewCell.h"
#import "WMDeviceGroup.h"
#import "WMInterventionStatus.h"

@interface WMDevicesGroupTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMDevicesGroupTableViewCell

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *DevicesGroupTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DevicesGroupTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return DevicesGroupTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *DevicesGroupTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DevicesGroupTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                                    paragraphStyle, NSParagraphStyleAttributeName,
                                                    nil];
    });
    return DevicesGroupTitleSelectedAttributes;
}

+ (NSDictionary *)valueAttributes
{
    static NSDictionary *DevicesGroupValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DevicesGroupValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return DevicesGroupValueAttributes;
}

+ (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *DevicesGroupValueSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DevicesGroupValueSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                                    paragraphStyle, NSParagraphStyleAttributeName,
                                                    nil];
    });
    return DevicesGroupValueSelectedAttributes;
}

- (void)setDevicesGroup:(WMDeviceGroup *)devicesGroup
{
    if (_devicesGroup == devicesGroup) {
        return;
    }
    // else
    [self willChangeValueForKey:@"devicesGroup"];
    _devicesGroup = devicesGroup;
    [self didChangeValueForKey:@"devicesGroup"];
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
    NSString *string = self.devicesGroup.status.title;
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMDevicesGroupTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMDevicesGroupTableViewCell titleAttributes];
    }
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    // draw date modified
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMDevicesGroupTableViewCell valueSelectedAttributes];
    } else {
        textAttributes = [WMDevicesGroupTableViewCell valueAttributes];
    }
    string = [NSDateFormatter localizedStringFromDate:self.devicesGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    aSize = [string sizeWithAttributes:textAttributes];
    x = (maxX - aSize.width);
    y = roundf((height - aSize.height)/2.0);
    [string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
}

@end

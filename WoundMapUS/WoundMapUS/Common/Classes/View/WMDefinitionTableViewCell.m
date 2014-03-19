//
//  WMDefinitionTableViewCell.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/19/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMDefinitionTableViewCell.h"
#import "WMDefinition.h"

@interface WMDefinitionTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@end

@implementation WMDefinitionTableViewCell

@synthesize definition=_definition;
@dynamic isHighlightedOrSelected;

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *DefinitionTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                            [UIColor blackColor], NSForegroundColorAttributeName,
                            paragraphStyle, NSParagraphStyleAttributeName,
                            nil];
    });
    return DefinitionTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *DefinitionTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                     paragraphStyle, NSParagraphStyleAttributeName,
                                     nil];
    });
    return DefinitionTitleSelectedAttributes;
}

+ (NSDictionary *)descAttributes
{
    static NSDictionary *DefinitionDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return DefinitionDescAttributes;
}

+ (NSDictionary *)descSelectedAttributes
{
    static NSDictionary *DefinitionDescSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSLineBreakByWordWrapping;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionDescSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return DefinitionDescSelectedAttributes;
}

+ (NSDictionary *)descFullAttributes
{
    static NSDictionary *DefinitionDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DefinitionDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return DefinitionDescAttributes;
}

- (void)setDefinition:(WMDefinition *)definition
{
    if (_definition == definition) {
        return;
    }
    // else
    [self willChangeValueForKey:@"definition"];
    _definition = definition;
    [self didChangeValueForKey:@"definition"];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

+ (CGFloat)heightThatFitsDefinition:(WMDefinition *)definition fullDescription:(BOOL)fullDescription width:(CGFloat)width
{
    // allow for right margin
    width -= 8.0;
    CGFloat height = 8.0;
    height += ceilf([definition.term sizeWithAttributes:[self titleAttributes]].height);
    height += ceilf([definition.definition boundingRectWithSize:CGSizeMake(width, 5000.0)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                     attributes:(fullDescription ? [self descFullAttributes]:[self descAttributes])
                                                  context:nil].size.height);
    return fmaxf(44.0, height);
}

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    CGFloat width = CGRectGetWidth(rect);
    // allow for right margin
    width -= 8.0;
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = 4.0;
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMDefinitionTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMDefinitionTableViewCell titleAttributes];
    }
    NSString *string = self.definition.term;
    CGRect textRect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(width, 5000.0)
                                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       attributes:textAttributes
                                                          context:nil]);
    textRect.origin.x = x;
    textRect.origin.y = y;
    [string drawInRect:textRect withAttributes:textAttributes];
    y +=  CGRectGetHeight(textRect);
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMDefinitionTableViewCell descSelectedAttributes];
    } else {
        textAttributes = (self.drawFullDescription ? [WMDefinitionTableViewCell descFullAttributes]:[WMDefinitionTableViewCell descAttributes]);
    }
    string = self.definition.definition;
    textRect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(width, 5000.0)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:textAttributes
                                                   context:nil]);
    textRect.origin.x = x;
    textRect.origin.y = y;
    [string drawInRect:textRect withAttributes:textAttributes];
}

@end

//
//  WMInstructionTableViewCell.m
//  WoundMAP
//
//  Created by Todd Guion on 11/18/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMInstructionTableViewCell.h"

@implementation WMInstructionTableViewCell

- (void)setTitle:(NSString *)title
{
    if ([_title isEqualToString:title]) {
        return;
    }
    // else
    [self willChangeValueForKey:@"title"];
    _title = title;
    [self didChangeValueForKey:@"title"];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    if ([_text isEqualToString:text]) {
        return;
    }
    // else
    [self willChangeValueForKey:@"text"];
    _text = text;
    [self didChangeValueForKey:@"text"];
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    CGFloat viewWidth = CGRectGetWidth(rect);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect) + _verticalMargin;
    CGFloat x = minX;
    CGFloat y = minY;
    CGSize aSize = [_title sizeWithAttributes:_titleAttributes];
    [_title drawAtPoint:CGPointMake(x, y) withAttributes:_titleAttributes];
    y += ceilf(aSize.height);
    CGRect textRect = CGRectIntegral([_text boundingRectWithSize:CGSizeMake(viewWidth, 5000.0)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:_textAttributes
                                                         context:nil]);
    textRect.origin.x = x;
    textRect.origin.y = y;
    [_text drawInRect:textRect withAttributes:_textAttributes];
}

+ (CGFloat)heightForTitle:(NSString *)title
                     text:(NSString *)text
          titleAttributes:(NSDictionary *)titleAttributes
           textAttributes:(NSDictionary *)textAttributes
                    width:(CGFloat)width
           verticalMargin:(CGFloat)verticalMargin
{
    CGFloat height = 2.0 * verticalMargin;
    height += [title sizeWithAttributes:titleAttributes].height;
    height += [text boundingRectWithSize:CGSizeMake(width, 5000.0)
                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                              attributes:textAttributes
                                 context:nil].size.height;
    return fmaxf(44.0, ceilf(height));
}

@end

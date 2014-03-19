//
//  WMIAPProductTextTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 11/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMIAPProductTextTableViewCell.h"

@implementation WMIAPProductTextTableViewCell

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
    CGFloat viewWidth = CGRectGetWidth(rect) - self.separatorInset.left - self.separatorInset.right;
    CGFloat viewHeight = CGRectGetHeight(rect);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGRect textRect = [self.text boundingRectWithSize:CGSizeMake(viewWidth, 5000.0)
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:self.textAttributes
                                              context:nil];
    CGFloat textHeight = ceilf(textRect.size.height);
    CGFloat deltaY = roundf((viewHeight - textHeight)/2.0);
    rect = CGRectMake(minX + self.separatorInset.left, minY + deltaY, viewWidth, textHeight);
    [self.text drawInRect:rect withAttributes:self.textAttributes];
}

@end

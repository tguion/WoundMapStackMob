//
//  BoxedButton.m
//  WoundMAP
//
//  Created by Todd Guion on 12/9/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "BoxedButton.h"

@implementation BoxedButton

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    // draw lines
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    BOOL retinaFlag = [[UIScreen mainScreen] scale] >= 2.0;
    CGContextSetLineWidth(context, (retinaFlag ? 0.5:1.0));
    CGFloat offsetY = (retinaFlag ? 0.25:0.5);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.82 alpha:1.0] CGColor]);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minX, minY + offsetY);
    CGContextAddLineToPoint(context, maxX, minY + offsetY);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minX, maxY - offsetY);
    CGContextAddLineToPoint(context, maxX, maxY - offsetY);
    CGContextStrokePath(context);
}

@end

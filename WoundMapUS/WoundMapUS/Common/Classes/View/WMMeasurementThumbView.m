//
//  WMMeasurementThumbView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 9/20/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMMeasurementThumbView.h"
#import "WMThumbImageView.h"

@interface WMMeasurementThumbView ()
@property (readonly, nonatomic) WMThumbImageView *thumbnailImageView;
@end

@implementation WMMeasurementThumbView

- (WMThumbImageView *)thumbnailImageView
{
    return (WMThumbImageView *)[self viewWithTag:1000];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.thumbnailImageView.extendsTouchAlongX = !self.drawVerticalFlag;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [[UIColor redColor] set];
    const CGFloat lengths[] = {5.0, 2.0};
    CGContextSetLineDash(context, 0.0, lengths, 2);
    UIView *pointerView = [self viewWithTag:1000];
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    if (self.drawVerticalFlag) {
        x = floorf(pointerView.center.x + 0.5) + 0.5;
        y = roundf(CGRectGetMinY(pointerView.frame));
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x, 0.0);
        CGContextStrokePath(context);
    } else {
        x = roundf(CGRectGetMaxX(pointerView.frame));
        y = floorf(pointerView.center.y + 0.5) + 0.5;
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, CGRectGetWidth(rect), y);
        CGContextStrokePath(context);
    }
}

@end

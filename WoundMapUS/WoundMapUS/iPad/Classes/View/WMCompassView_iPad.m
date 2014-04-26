//
//  WMCompassView_iPad.m
//  WoundMAP
//
//  Created by Todd Guion on 11/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCompassView_iPad.h"
#import "WMDesignUtilities.h"
#import <QuartzCore/QuartzCore.h>

#define kPatientPanelWidth 100.0
#define kWoundPanelWidth 100.0

@implementation WMCompassView_iPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - CompassView

- (CGFloat)compassPanelMinX
{
    return kPatientPanelWidth;
}

- (CGFloat)compassPanelMaxX
{
    return (CGRectGetMaxX(self.bounds) - kWoundPanelWidth);
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // let super draw
    [super drawRect:rect];
    // now self draw
    CGContextRef context = UIGraphicsGetCurrentContext();
    // draw separators
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    // draw top line
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColorFromRGB(0xEAECEE) CGColor]);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minX + 0.5, minY + 0.5);
    CGContextAddLineToPoint(context, maxX + 0.5, minY + 0.5);
    CGContextStrokePath(context);
    // draw left patient line
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, kPatientPanelWidth + 0.5, minY);
    CGContextAddLineToPoint(context, kPatientPanelWidth + 0.5, maxY);
    CGContextStrokePath(context);
    // draw right wound line
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, maxX - kWoundPanelWidth + 0.5, minY);
    CGContextAddLineToPoint(context, maxX - kWoundPanelWidth + 0.5, maxY);
    CGContextStrokePath(context);
    // draw bottom line
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minX, maxY - 0.5);
    CGContextAddLineToPoint(context, maxX, maxY - 0.5);
    CGContextStrokePath(context);
}

@end

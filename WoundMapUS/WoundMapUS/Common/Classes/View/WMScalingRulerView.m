//
//  WMScalingRulerView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 8/7/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMScalingRulerView.h"
#import <QuartzCore/QuartzCore.h>

#define MEASUREMENT_OVERLAY_DEFAULT_PT_PER_CM 44.0

@interface WMScalingRulerView ()

@end

@implementation WMScalingRulerView

@synthesize boxOffset=_boxOffset;
@synthesize scaleFactor=_scaleFactor;
@dynamic pointsPerCentimeter;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // update state
    [self reset];
    // set the anchorPoints
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
}

- (void)reset
{
    self.boxOffset = 8.0;
    self.scaleFactor = 1.0;
    self.transform = CGAffineTransformIdentity;
}

- (void)setBoxOffset:(CGFloat)boxOffset
{
    if (_boxOffset == boxOffset) {
        return;
    }
    // else
    [self willChangeValueForKey:@"boxOffset"];
    _boxOffset = boxOffset;
    [self didChangeValueForKey:@"boxOffset"];
    [self setNeedsDisplay];
}

- (void)setScaleFactor:(CGFloat)scaleFactor
{
    if (_scaleFactor == scaleFactor) {
        return;
    }
    // else
    [self willChangeValueForKey:@"scaleFactor"];
    _scaleFactor = scaleFactor;
    [self didChangeValueForKey:@"scaleFactor"];
    [self setNeedsDisplay];
}

- (CGFloat)pointsPerCentimeter
{
    return self.scaleFactor * MEASUREMENT_OVERLAY_DEFAULT_PT_PER_CM;
}

- (void)drawRect:(CGRect)rect
{
    //    DLog(@"%@.drawRect scale %f translation %@ rotation %f", NSStringFromClass([self class]), self.scaleFactor, NSStringFromCGPoint(self.translationDelta), self.rotationDelta);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // apply transforms
    CGContextSetLineWidth(context, 1.0);
    [[UIColor whiteColor] set];
    rect = CGRectInset(rect, roundf(CGRectGetWidth(rect)/self.boxOffset) - 0.5, roundf(CGRectGetHeight(rect)/self.boxOffset) - 0.5);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    // draw outer rect
    CGContextStrokeRect(context, rect);
    // determine distance between major ticks
    CGFloat deltaMajor = self.pointsPerCentimeter;
    CGFloat deltaMinor = roundf(deltaMajor/5.0);
    // size ticks
    CGFloat majorTickLength = 20.0;
    CGFloat minorTickLength = 5.0;
    // calculate horizontal bottom ticks - skip the first tickmark
    CGFloat x = minX + majorTickLength;
    CGFloat y = maxY;
    CGFloat xr = x;
    CGFloat yr = y;
    CGFloat xmr = 0.0;
    CGFloat ymr = 0.0;
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:36];
    while (x < (maxX - deltaMajor)) {
        // major tick
        xr = floorf(x + 0.5) + 0.5;
        CGPoint p1 = CGPointMake(xr, y);
        CGPoint p2 = CGPointMake(xr, y - majorTickLength);
        NSValue *value = [NSValue valueWithCGPoint:p1];
        [points addObject:value];
        value = [NSValue valueWithCGPoint:p2];
        [points addObject:value];
        // minor tick
        CGFloat xm = x + deltaMinor;
        for (int i=0; i<4; ++i) {
            if (xm >= maxX) {
                break;
            }
            xmr = floorf(xm + 0.5) + 0.5;
            p1 = CGPointMake(xm, y);
            p2 = CGPointMake(xm, y - minorTickLength);
            value = [NSValue valueWithCGPoint:p1];
            [points addObject:value];
            value = [NSValue valueWithCGPoint:p2];
            [points addObject:value];
            xm += deltaMinor;
        }
        x += deltaMajor;
    }
    // draw horizontal bottom
    for (int i=0; i<[points count]; ) {
        NSValue *value = (NSValue *)[points objectAtIndex:i++];
        CGPoint p1 = [value CGPointValue];
        value = (NSValue *)[points objectAtIndex:i++];
        CGPoint p2 = [value CGPointValue];
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
        CGContextStrokePath(context);
    }
    // calculate vertical left ticks
    x = minX;
    y = maxY - deltaMajor;
    [points removeAllObjects];
    while (y > (minY + deltaMajor)) {
        yr = floorf(y + 0.5) + 0.5;
        // major tick
        CGPoint p1 = CGPointMake(x, yr);
        CGPoint p2 = CGPointMake(x + majorTickLength, yr);
        NSValue *value = [NSValue valueWithCGPoint:p1];
        [points addObject:value];
        value = [NSValue valueWithCGPoint:p2];
        [points addObject:value];
        // minor tick
        CGFloat ym = y - deltaMinor;
        for (int i=0; i<4; ++i) {
            if (ym <= minY) {
                break;
            }
            ymr = floorf(ym + 0.5) + 0.5;
            p1 = CGPointMake(x, ymr);
            p2 = CGPointMake(x + minorTickLength, ymr);
            value = [NSValue valueWithCGPoint:p1];
            [points addObject:value];
            value = [NSValue valueWithCGPoint:p2];
            [points addObject:value];
            ym -= deltaMinor;
        }
        y -= deltaMajor;
    }
    // draw vertical left
    for (int i=0; i<[points count]; ) {
        NSValue *value = (NSValue *)[points objectAtIndex:i++];
        CGPoint p1 = [value CGPointValue];
        value = (NSValue *)[points objectAtIndex:i++];
        CGPoint p2 = [value CGPointValue];
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
        CGContextStrokePath(context);
    }
    //    CGContextRestoreGState(context);
}

@end

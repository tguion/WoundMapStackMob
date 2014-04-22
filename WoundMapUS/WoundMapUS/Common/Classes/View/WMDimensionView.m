//
//  WMDimensionView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/17/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMDimensionView.h"

@interface WMDimensionView ()
@property (nonatomic) CGFloat minX;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat pointsPerCentimeter;
@end

@implementation WMDimensionView

- (void)updateForRect:(CGRect)woundRect pointsPerCentimeter:(CGFloat)pointsPerCentimeter transform:(CGAffineTransform)transform
{
    self.minX = CGRectGetMinX(woundRect);
    self.maxX = CGRectGetMaxX(woundRect);
    self.minY = CGRectGetMinY(woundRect);
    self.maxY = CGRectGetMaxY(woundRect);
    self.pointsPerCentimeter = pointsPerCentimeter;
    self.transform = transform;
    [self setNeedsDisplay];
}

+ (NSDictionary *)normalAttributes
{
    static NSDictionary *DimensionAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DimensionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                               [UIColor redColor], NSForegroundColorAttributeName,
                               paragraphStyle, NSParagraphStyleAttributeName,
                               nil];
    });
    return DimensionAttributes;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [[UIColor redColor] set];
    CGFloat width = self.maxX - self.minX;
    CGFloat height = self.maxY - self.minY;
    NSString *widthValue = [NSString stringWithFormat:@"%0.1f", width / self.pointsPerCentimeter];
    NSString *heightValue = [NSString stringWithFormat:@"%0.1f", height / self.pointsPerCentimeter];
    // draw x-dimension value
    CGSize aSize = [widthValue sizeWithAttributes:[WMDimensionView normalAttributes]];
    CGFloat x = self.minX + roundf((self.maxX - self.minX - aSize.width)/2.0);
    CGFloat y = self.maxY + 2.0;
    [widthValue drawAtPoint:CGPointMake(x, y) withAttributes:[WMDimensionView normalAttributes]];
    CGFloat valueLeft = x - 2.0;
    CGFloat valueRight = x + aSize.width + 2.0;
    x = self.minX;
    y = self.maxY + 2.0 + roundf(aSize.height/2.0) - 0.5;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, valueLeft, y);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, valueRight, y);
    CGContextAddLineToPoint(context, self.maxX, y);
    CGContextStrokePath(context);
    // arrows
    x = self.minX;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + 4.0, y - 4.0);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + 4.0, y + 4.0);
    CGContextStrokePath(context);
    x = self.maxX;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x - 4.0, y - 4.0);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x - 4.0, y + 4.0);
    CGContextStrokePath(context);
    // draw y-dimension
    aSize = [heightValue sizeWithAttributes:[WMDimensionView normalAttributes]];
    x = self.minX - aSize.width - 2.0;
    y = self.minY + roundf((self.maxY - self.minY - aSize.height)/2.0);
    [heightValue drawAtPoint:CGPointMake(x, y) withAttributes:[WMDimensionView normalAttributes]];
    CGFloat valueTop = y - 2.0;
    CGFloat valueBottom = y + aSize.height + 2.0;
    x = self.minX - roundf(aSize.width/2.0) - 0.5;
    y = self.minY;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x, valueTop);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, valueBottom);
    CGContextAddLineToPoint(context, x, self.maxY);
    CGContextStrokePath(context);
    // arrows
    y = self.minY;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + 4.0, y + 4.0);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x - 4.0, y + 4.0);
    CGContextStrokePath(context);
    y = self.maxY;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x - 4.0, y - 4.0);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + 4.0, y - 4.0);
    CGContextStrokePath(context);
}

@end

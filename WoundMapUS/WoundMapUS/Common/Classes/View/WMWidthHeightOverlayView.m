//
//  WMWidthHeightOverlayView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 9/19/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMWidthHeightOverlayView.h"
#import "WMMeasurementThumbView.h"
#import <QuartzCore/QuartzCore.h>

@interface WMWidthHeightOverlayView ()
@property (weak, nonatomic) IBOutlet WMMeasurementThumbView *x1View;
@property (weak, nonatomic) IBOutlet WMMeasurementThumbView *x2View;
@property (weak, nonatomic) IBOutlet WMMeasurementThumbView *y1View;
@property (weak, nonatomic) IBOutlet WMMeasurementThumbView *y2View;
@end

@interface WMWidthHeightOverlayView (PrivateMethods)
- (void)layoutPointers;
@end

@implementation WMWidthHeightOverlayView (PrivateMethods)

- (void)layoutPointers
{
    CGRect rect = CGRectInset(self.bounds, roundf(CGRectGetWidth(self.bounds)/self.boxOffset) - 0.5, roundf(CGRectGetHeight(self.bounds)/self.boxOffset) - 0.5);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    UIView *anImage = [self.x1View viewWithTag:1000];
    CGPoint center = anImage.center;
    center.y = maxY;
    anImage.center = center;
    anImage = [self.x2View viewWithTag:1000];
    center = anImage.center;
    center.y = maxY;
    anImage.center = center;
    anImage = [self.y1View viewWithTag:1000];
    center = anImage.center;
    center.x = minX;
    anImage.center = center;
    anImage = [self.y2View viewWithTag:1000];
    center = anImage.center;
    center.x = minX;
    anImage.center = center;
}

@end

@implementation WMWidthHeightOverlayView

@synthesize delegate;
@synthesize boxOffset=_boxOffset, pointsPerCentimeter=_pointsPerCentimeter, translationDelta=_translationDelta, resetCalled;
@dynamic woundRect;

- (CGRect)woundRect
{
    CGFloat x = MIN(self.x1View.center.x, self.x2View.center.x);
    CGFloat y = MIN(self.y1View.center.y, self.y2View.center.y);
    CGFloat width = fabsf(self.x2View.center.x - self.x1View.center.x);
    CGFloat height = fabsf(self.y2View.center.y - self.y1View.center.y);
    return CGRectMake(x, y, width, height);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // set state
    self.boxOffset = 8.0;
    self.translationDelta = CGPointZero;
    // set backgrounds
    self.x1View.backgroundColor = [UIColor clearColor];
    self.x2View.backgroundColor = [UIColor clearColor];
    self.y1View.backgroundColor = [UIColor clearColor];
    self.y2View.backgroundColor = [UIColor clearColor];
    // set directions
    self.x1View.drawVerticalFlag = YES;
    self.x2View.drawVerticalFlag = YES;
    self.y1View.drawVerticalFlag = NO;
    self.y2View.drawVerticalFlag = NO;
    // add gesture recognizers to pointer image
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleV1PanGesture:)];
    [[self.x1View viewWithTag:1000] addGestureRecognizer:gestureRecognizer];
    gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleV2PanGesture:)];
    [[self.x2View viewWithTag:1000] addGestureRecognizer:gestureRecognizer];
    gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleH1PanGesture:)];
    [[self.y1View viewWithTag:1000] addGestureRecognizer:gestureRecognizer];
    gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleH2PanGesture:)];
    [[self.y2View viewWithTag:1000] addGestureRecognizer:gestureRecognizer];
}

- (void)resetWithPointsPerCentemeter:(CGFloat)pointsPerCentemeter
{
    self.transform = CGAffineTransformIdentity;
    self.pointsPerCentimeter = pointsPerCentemeter;
    // position pointers
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    CGRect frame = self.x1View.frame;
    frame.size.height = boundsHeight;
    frame.origin.y = 0.0;
    self.x1View.frame = frame;
    self.x2View.frame = frame;
    frame = self.y1View.frame;
    frame.size.width = boundsWidth;
    frame.origin.x = 0.0;
    self.y1View.frame = frame;
    self.y2View.frame = frame;
    CGRect rect = CGRectInset(self.bounds, roundf(boundsWidth/self.boxOffset) - 0.5, roundf(boundsHeight/self.boxOffset) - 0.5);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGPoint center = self.x1View.center;
    center.x = roundf(minX + width/4.0);
    self.x1View.center = center;
    center = self.x2View.center;
    center.x = roundf(minX + width * 3.0/4.0);
    self.x2View.center = center;
    center = self.y1View.center;
    center.y = roundf(maxY -  height/4.0);
    self.y1View.center = center;
    center = self.y2View.center;
    center.y = roundf(maxY - height * 3.0/4.0);
    self.y2View.center = center;
    // position images in pointers
    [self layoutPointers];
    // set state
    self.resetCalled = YES;
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
    [self.x1View setNeedsDisplay];
    [self.x2View setNeedsDisplay];
    [self.y1View setNeedsDisplay];
    [self.y2View setNeedsDisplay];
}

- (void)setPointsPerCentimeter:(CGFloat)pointsPerCentimeter
{
    if (_pointsPerCentimeter == pointsPerCentimeter) {
        return;
    }
    // else
    [self willChangeValueForKey:@"pointsPerCentimeter"];
    _pointsPerCentimeter = pointsPerCentimeter;
    [self didChangeValueForKey:@"pointsPerCentimeter"];
    [self setNeedsDisplay];
}

- (void)setTranslationDelta:(CGPoint)translationDelta
{
    if (CGPointEqualToPoint(_translationDelta, translationDelta)) {
        return;
    }
    // else
    [self willChangeValueForKey:@"translationDelta"];
    _translationDelta = translationDelta;
    [self didChangeValueForKey:@"translationDelta"];
    // move the pointers
    self.x1View.transform = CGAffineTransformTranslate(self.x1View.transform, translationDelta.x, translationDelta.y);
    self.x2View.transform = CGAffineTransformTranslate(self.x2View.transform, translationDelta.x, translationDelta.y);
    self.y1View.transform = CGAffineTransformTranslate(self.y1View.transform, translationDelta.x, translationDelta.y);
    self.y2View.transform = CGAffineTransformTranslate(self.y2View.transform, translationDelta.x, translationDelta.y);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [[UIColor redColor] set];
    rect = CGRectInset(rect, roundf(CGRectGetWidth(rect)/self.boxOffset) - 0.5, roundf(CGRectGetHeight(rect)/self.boxOffset) - 0.5);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    // draw axis
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minX, maxY);
    CGContextAddLineToPoint(context, maxX, maxY);
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minX, maxY);
    CGContextAddLineToPoint(context, minX, minY);
    CGContextStrokePath(context);
}

#pragma mark - Actions

- (IBAction)handleV1PanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGFloat delta = translation.x;
    CGPoint center = self.x1View.center;
    center.x += delta;
    self.x1View.center = center;
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
    [self.delegate widthHeightOverlayView:self didUpdateWoundRect:self.woundRect];
}

- (IBAction)handleV2PanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGFloat delta = translation.x;
    CGPoint center = self.x2View.center;
    center.x += delta;
    self.x2View.center = center;
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
    [self.delegate widthHeightOverlayView:self didUpdateWoundRect:self.woundRect];
}

- (IBAction)handleH1PanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGFloat delta = translation.y;
    CGPoint center = self.y1View.center;
    center.y += delta;
    self.y1View.center = center;
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
    [self.delegate widthHeightOverlayView:self didUpdateWoundRect:self.woundRect];
}

- (IBAction)handleH2PanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGFloat delta = translation.y;
    CGPoint center = self.y2View.center;
    center.y += delta;
    self.y2View.center = center;
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
    [self.delegate widthHeightOverlayView:self didUpdateWoundRect:self.woundRect];
}

@end

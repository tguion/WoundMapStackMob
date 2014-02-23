//
//  WMAdjustAlpaView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/20/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMAdjustAlpaView.h"
#import <QuartzCore/QuartzCore.h>

CGFloat const kInitialBackgroundImageAlpha = 0.15;

@interface WMAdjustAlpaView ()
@property (strong, nonatomic) UIImageView *sliderImageView;
@property (readonly, nonatomic) CGFloat currentAlpha;
@property (nonatomic) CGFloat sliderMinYCenter;
@property (nonatomic) CGFloat sliderMaxYCenter;
@end

@implementation WMAdjustAlpaView

@synthesize delegate=_delegate;
@synthesize sliderImageView=_sliderImageView;
@dynamic currentAlpha;
@synthesize sliderMinYCenter=_sliderMinYCenter, sliderMaxYCenter=_sliderMaxYCenter;

+ (Class)layerClass {
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<AdjustAlpaViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        _delegate = delegate;
        // position slider view
        [self reset];
        [self addSubview:self.sliderImageView];
        // add gesture recognizer to slider
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        [self.sliderImageView addGestureRecognizer:gestureRecognizer];
        // set gradient
        self.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.startPoint = CGPointMake(0.0, 0.5);
        gradientLayer.endPoint = CGPointMake(1.0, 0.5);
        UIColor *startColor = [UIColor colorWithWhite:0.0 alpha:0.25];
        UIColor *endColor = [UIColor colorWithWhite:1.0 alpha:0.0];
		gradientLayer.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
        // make adjustable
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark - Core

- (void)reset
{
    UIImageView *sliderImageView = self.sliderImageView;
    CGFloat sliderHeight = CGRectGetHeight(sliderImageView.bounds);
    CGFloat height = CGRectGetHeight(self.frame);
    CGRect aFrame = sliderImageView.frame;
    aFrame.origin.x = -8.0;
    aFrame.origin.y = sliderHeight + roundf((1.0 - self.delegate.initialAlpha) * (height - sliderHeight) - sliderHeight);
    sliderImageView.frame = aFrame;
    // update state
    self.sliderMinYCenter = -1.0;
    self.sliderMaxYCenter = -1.0;
}

- (UIImageView *)sliderImageView
{
    if (nil == _sliderImageView) {
        UIImage *image = [UIImage imageNamed:@"ui_slider_black.png"];
        _sliderImageView = [[UIImageView alloc] initWithImage:image];
        _sliderImageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        _sliderImageView.alpha = 0.45;
        _sliderImageView.userInteractionEnabled = YES;
    }
    return _sliderImageView;
}

- (CGFloat)currentAlpha
{
    return 1.0 - CGRectGetMinY(self.sliderImageView.frame)/(CGRectGetHeight(self.bounds) - CGRectGetHeight(self.sliderImageView.frame));
}

- (CGFloat)sliderMinYCenter
{
    if (_sliderMinYCenter == -1.0) {
        CGFloat sliderHeight = CGRectGetHeight(self.sliderImageView.frame);
        _sliderMinYCenter = roundf(sliderHeight/2.0);
    }
    return _sliderMinYCenter;
}

- (CGFloat)sliderMaxYCenter
{
    if (_sliderMaxYCenter == -1.0) {
        CGFloat sliderHeight = CGRectGetHeight(self.sliderImageView.frame);
        CGFloat maxY = CGRectGetHeight(self.bounds);
        _sliderMaxYCenter = roundf(maxY - sliderHeight/2.0);
    }
    return _sliderMaxYCenter;
}

- (void)flashViewAlpha
{
    _sliderImageView.alpha = 1.0;
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    UIColor *startColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    UIColor *endColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        UIColor *startColor = [UIColor colorWithWhite:0.0 alpha:0.25];
        UIColor *endColor = [UIColor colorWithWhite:1.0 alpha:0.0];
		gradientLayer.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
        weakSelf.sliderImageView.alpha = 0.45;
    }];
}

#pragma mark - Actions

- (IBAction)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGFloat delta = translation.y;
    CGPoint center = self.sliderImageView.center;
    center.y += delta;
    // bound top of slider to top of view
    if (center.y < self.sliderMinYCenter) {
        center.y = self.sliderMinYCenter;
    } else if (center.y > self.sliderMaxYCenter) {
        center.y = self.sliderMaxYCenter;
    }
    self.sliderImageView.center = center;
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
    [self.delegate adjustAlpaView:self didUpdateAlpha:self.currentAlpha];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    // draw dim/bright images
    UIImage *dimImage = [UIImage imageNamed:@"ui_dim.png"];
    CGFloat imageWidth = dimImage.size.width;
    CGFloat imageHeight = dimImage.size.height;
    CGRect aRect = CGRectMake(minX + 2.0, minY + CGRectGetHeight(rect) - imageHeight - 2.0, imageWidth, imageHeight);
    [dimImage drawInRect:aRect blendMode:kCGBlendModeNormal alpha:0.95];
    UIImage *brightImage = [UIImage imageNamed:@"ui_bright.png"];
    imageWidth = brightImage.size.width;
    imageHeight = brightImage.size.height;
    aRect = CGRectMake(minX + 2.0, minY + 2.0, imageWidth, imageHeight);
    [brightImage drawInRect:aRect blendMode:kCGBlendModeNormal alpha:0.95];
}

@end

//
//  WMProgressViewHUD.m
//  iTC Mobile
//
//  Created by Todd Guion on 2/3/12.
//  Copyright (c) 2012 Apple. All rights reserved.
//

#import "WMProgressViewHUD.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_WIDTH 280.0
#define MAX_HEIGHT 120.0

@interface WMProgressViewHUD (PrivateMethods)
- (void)initialize;
@end

@implementation WMProgressViewHUD (PrivateMethods)

- (void)initialize
{
    self.layer.opaque = NO;
    self.layer.opacity = 0.75;
    self.layer.cornerRadius = 12.0;
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
    self.layer.masksToBounds = YES;
    self.layer.shouldRasterize = YES;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeMake(3.0, 3.0);
    self.layer.shadowOpacity = 0.55;
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.frame = CGRectMake(0.0, 0.0, MAX_WIDTH, MAX_HEIGHT);
}

@end

@implementation WMProgressViewHUD

@synthesize activityIndicatorView=_activityIndicatorView, messageLabel=_messageLabel;

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (nil == _activityIndicatorView) {
        UIActivityIndicatorView *aView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        aView.tag = 100;
        [aView startAnimating];
        [self addSubview:aView];
        _activityIndicatorView = aView;
    }
    return _activityIndicatorView;
}

- (UILabel *)messageLabel
{
    if (nil == _messageLabel) {
        UILabel *aView = [[UILabel alloc] initWithFrame:CGRectZero];
        aView.tag = 200;
        aView.text = @"Loading...";
        aView.textAlignment = NSTextAlignmentCenter;
        aView.textColor = [UIColor lightTextColor];
        aView.backgroundColor = [UIColor clearColor];
        aView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [aView sizeToFit];
        [self addSubview:aView];
        _messageLabel = aView;
    }
    return _messageLabel;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (nil == newSuperview) {
        [_activityIndicatorView removeFromSuperview];
        _activityIndicatorView = nil;
        [_messageLabel removeFromSuperview];
        _messageLabel = nil;
    } else {
        // center
        CGPoint aCenter = CGPointMake(CGRectGetMidX(newSuperview.bounds), CGRectGetMidY(newSuperview.bounds));
        self.center = aCenter;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)setCenter:(CGPoint)center
{
    if (nil != self.superview) {
        CGFloat centerWidth = CGRectGetMidX(self.superview.bounds);
        CGFloat centerHeight = CGRectGetMidY(self.superview.bounds);
        if (center.x != centerWidth) {
            center.x = centerWidth;
        }
        if (center.y != centerHeight) {
            center.y = centerHeight;
        }
    }
    [super setCenter:center];
}

- (void)setFrame:(CGRect)frame
{
    if (CGRectGetWidth(frame) > MAX_WIDTH) {
        frame.size.width = MAX_WIDTH;
    }
    if (CGRectGetHeight(frame) > MAX_HEIGHT) {
        frame.size.height = MAX_HEIGHT;
    }
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGRect aFrame = self.messageLabel.frame;
    aFrame.size.width = width;
    self.messageLabel.frame = aFrame;
    self.messageLabel.center = CGPointMake(width/2.0, height/2.0 + CGRectGetHeight(self.messageLabel.frame)/2.0);
    self.activityIndicatorView.center = CGPointMake(width/2.0, height/2.0 - CGRectGetHeight(self.activityIndicatorView.frame)/2.0);
}

@end

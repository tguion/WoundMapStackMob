//
//  WMUndermineTunnelContainerView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 3/24/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMUndermineTunnelContainerView.h"
#import <QuartzCore/QuartzCore.h>

@interface WMUndermineTunnelContainerView ()

@property (weak, nonatomic) CAGradientLayer *shineLayer;

@property (weak, nonatomic) IBOutlet UIPickerView *fromPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *toPickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedWidthBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextField *depthTextField;
@property (weak, nonatomic) IBOutlet UILabel *fromOClockLabel;
@property (weak, nonatomic) IBOutlet UILabel *toOClockLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (nonatomic) CGFloat pickerViewsWidth;

- (void)initLayers;

@end

@implementation WMUndermineTunnelContainerView

@synthesize shineLayer=_shineLayer;
@synthesize state=_state, pickerViewsWidth=_pickerViewsWidth;

+ (Class)layerClass {
	return [CAGradientLayer class];
}

- (void)initLayers {
    CAGradientLayer *aLayer = [CAGradientLayer layer];
    aLayer.frame = self.layer.bounds;
    aLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    aLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [self.layer addSublayer:aLayer];
    self.shineLayer = aLayer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (CGFloat)pickerViewsWidth
{
    if (0.0 == _pickerViewsWidth) {
        _pickerViewsWidth = (CGRectGetWidth(self.toPickerView.frame) + CGRectGetWidth(self.toLabel.frame) + CGRectGetWidth(self.fromPickerView.frame));
    }
    return _pickerViewsWidth;
}

- (void)setState:(UndermineTunnelContainerViewState)state
{
    if (_state == state) {
        return;
    }
    // else
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
    switch (self.state) {
        case UndermineTunnelContainerViewState_Undermine: {
            self.toPickerView.hidden = NO;
            self.toLabel.hidden = NO;
            self.toOClockLabel.hidden = NO;
            break;
        }
        case UndermineTunnelContainerViewState_Tunnel: {
            self.toPickerView.hidden = YES;
            self.toLabel.hidden = YES;
            self.toOClockLabel.hidden = YES;
            break;
        }
        default:
            break;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    switch (self.state) {
        case UndermineTunnelContainerViewState_Undermine: {
            CGFloat x = roundf((width - self.pickerViewsWidth)/2.0);
            CGRect aFrame = self.fromPickerView.frame;
            aFrame.origin.x = x;
            self.fromPickerView.frame = aFrame;
            x += CGRectGetWidth(aFrame);
            aFrame = self.toLabel.frame;
            aFrame.origin.x = x;
            self.toLabel.frame = aFrame;
            x += CGRectGetWidth(aFrame);
            aFrame = self.toPickerView.frame;
            aFrame.origin.x = x;
            self.toPickerView.frame = aFrame;
            aFrame = self.fromOClockLabel.frame;
            aFrame.origin.x = CGRectGetMinX(self.fromPickerView.frame);
            self.fromOClockLabel.frame = aFrame;
            aFrame = self.toOClockLabel.frame;
            aFrame.origin.x = CGRectGetMinX(self.toPickerView.frame);
            self.toOClockLabel.frame = aFrame;
            self.fixedWidthBarButtonItem.width = 0.0;//CGRectGetMinX(self.fromPickerView.frame);
            break;
        }
        case UndermineTunnelContainerViewState_Tunnel: {
            CGFloat x = roundf((width - CGRectGetWidth(self.fromPickerView.frame))/2.0);
            CGRect aFrame = self.fromPickerView.frame;
            aFrame.origin.x = x;
            self.fromPickerView.frame = aFrame;
            aFrame = self.fromOClockLabel.frame;
            aFrame.origin.x = CGRectGetMinX(self.fromPickerView.frame);
            self.fromOClockLabel.frame = aFrame;
            self.fixedWidthBarButtonItem.width = 0.0;
            break;
        }
        default:
            break;
    }
}

@end

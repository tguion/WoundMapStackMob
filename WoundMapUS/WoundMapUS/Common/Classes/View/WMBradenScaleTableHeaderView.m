//
//  WMBradenScaleTableHeaderView.m
//  WoundCare
//
//  Created by Todd Guion on 8/3/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//
//  TODO: handle low memory and document close/delete: see WMWoundPhotoCollectionViewCell

#import "WMBradenScaleTableHeaderView.h"
#import "WMBradenScale.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMBradenScaleTableHeaderView ()
@property (readonly, nonatomic) UIFont *scoreFont;
@property (readonly, nonatomic) UIFont *messageFont;
@property (readonly, nonatomic) UILabel *scoreLabel;
@property (readonly, nonatomic) UILabel *messageLabel;
@end

@implementation WMBradenScaleTableHeaderView

@synthesize bradenScale=_bradenScale;
@dynamic scoreFont, messageFont;
@dynamic scoreLabel, messageLabel;

- (UIFont *)scoreFont
{
    return [UIFont boldSystemFontOfSize:17.0];
}

- (UIFont *)messageFont
{
    return [UIFont systemFontOfSize:13.0];
}

- (CGFloat)recommendedHeight
{
    return 64.0;
}

- (void)setBradenScale:(WMBradenScale *)bradenScale
{
    if (_bradenScale == bradenScale) {
        return;
    }
    // else
    [_bradenScale removeObserver:self forKeyPath:@"score"];
    [self willChangeValueForKey:@"bradenScale"];
    _bradenScale = bradenScale;
    [self didChangeValueForKey:@"bradenScale"];
    [bradenScale addObserver:self
                  forKeyPath:@"score"
                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                     context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	self.scoreLabel.text = [NSString stringWithFormat:@"Score: %@", self.bradenScale.score];
    if (self.bradenScale.completeFlagValue) {
        self.messageLabel.text = self.bradenScale.scoreMessage;
    } else {
        self.messageLabel.text = @"incomplete";
    }
    [self setNeedsLayout];
}

- (UILabel *)scoreLabel
{
	return (UILabel *)[self viewWithTag:100];
}

- (UILabel *)messageLabel
{
    return (UILabel *)[self viewWithTag:102];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Score label
        CGRect aFrame = frame;
        aFrame.origin.y += 8.0;
        aFrame.size.height -= 8.0;
        aFrame.size.height /= 2.0;
        aFrame = CGRectInset(aFrame, 8.0, 2.0);
		UILabel *aLabel = [[UILabel alloc] initWithFrame:aFrame];
        aLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        aLabel.backgroundColor = [UIColor clearColor];
        aLabel.text = @"Score: 0";
        aLabel.textAlignment = NSTextAlignmentCenter;
		aLabel.tag = 100;
		aLabel.font = self.scoreFont;
		[self addSubview:aLabel];
        // message
        aFrame.origin.y += CGRectGetHeight(aFrame);
        aLabel = [[UILabel alloc] initWithFrame:aFrame];
        aLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        aLabel.backgroundColor = [UIColor clearColor];
        aLabel.tag = 102;
        aLabel.font = self.messageFont;
        aLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:aLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect aFrame = self.bounds;
    aFrame.origin.y += 8.0;
    aFrame.size.height -= 8.0;
    aFrame.size.height /= 2.0;
    aFrame = CGRectInset(aFrame, 8.0, 2.0);
    UILabel *aLabel = self.scoreLabel;
    aLabel.frame = aFrame;
    aFrame.origin.y += CGRectGetHeight(aFrame);
    self.messageLabel.frame = aFrame;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
	if (nil == newSuperview) {
		self.bradenScale = nil;
	}
}

@end

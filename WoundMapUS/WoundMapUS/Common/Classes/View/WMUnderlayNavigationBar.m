//
//  WMUnderlayNavigationBar.m
//  WoundMAP
//
//  Created by Todd Guion on 11/28/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMUnderlayNavigationBar.h"
#import "WMDesignUtilities.h"

@interface WMUnderlayNavigationBar ()
{
	UIView* _underlayView;
}

- (UIView*) underlayView;

@end

@implementation WMUnderlayNavigationBar

- (void) didAddSubview:(UIView *)subview
{
	[super didAddSubview:subview];
    
	if(subview != _underlayView)
	{
		UIView* underlayView = self.underlayView;
		[underlayView removeFromSuperview];
		[self insertSubview:underlayView atIndex:1];
	}
}

- (UIView*) underlayView
{
	if(_underlayView == nil)
	{
		const CGFloat statusBarHeight = 0.0;    //  Make this dynamic in your own code...
		const CGSize selfSize = self.frame.size;
        
		_underlayView = [[UIView alloc] initWithFrame:CGRectMake(0, -statusBarHeight, selfSize.width, selfSize.height + statusBarHeight)];
		[_underlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[_underlayView setBackgroundColor:[WMDesignUtilities tintColorForBarInPopoverPUMP]];
		[_underlayView setAlpha:0.36f];
		[_underlayView setUserInteractionEnabled:NO];
	}
    
	return _underlayView;
}

@end

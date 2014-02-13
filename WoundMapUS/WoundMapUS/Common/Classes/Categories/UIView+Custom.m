//
//  UIView+Custom.m
//  iTCKingPrototype
//
//  Created by Todd Guion on 10/7/11.
//  Copyright (c) 2011 etreasure consulting inc. All rights reserved.
//

#import "UIView+Custom.h"

@implementation UIView (CustomCode)

- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {        
        return self;     
    }
	// else
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
	// else
    return nil;
}

- (void)checkViews:(NSArray *)subviews
{
    Class AVClass = [UIAlertView class];
    Class ASClass = [UIActionSheet class];
    for (UIView * subview in subviews){
        if ([subview isKindOfClass:AVClass]){
            [(UIAlertView *)subview dismissWithClickedButtonIndex:[(UIAlertView *)subview cancelButtonIndex] animated:NO];
        } else if ([subview isKindOfClass:ASClass]){
            [(UIActionSheet *)subview dismissWithClickedButtonIndex:[(UIActionSheet *)subview cancelButtonIndex] animated:NO];
        } else {
            [self checkViews:subview.subviews];
        }
    }
}

@end

//
//  WMThumbImageView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 3/16/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMThumbImageView.h"

@implementation WMThumbImageView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat deltaX = (_extendsTouchAlongX ? 88.0:44.0);
    CGFloat deltaY = (_extendsTouchAlongX ? 44.0:88.0);
    CGRect aRect = CGRectInset(self.bounds, (width - deltaX)/2.0, (height - deltaY)/2.0);
    return CGRectContainsPoint(aRect, point);
}

@end

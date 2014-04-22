//
//  WMNormalizingView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/16/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMNormalizingView.h"

@implementation WMNormalizingView

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end

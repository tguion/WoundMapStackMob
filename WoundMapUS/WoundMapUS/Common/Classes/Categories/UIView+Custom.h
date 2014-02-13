//
//  UIView+Custom.h
//  iTCKingPrototype
//
//  Created by Todd Guion on 10/7/11.
//  Copyright (c) 2011 Apple Inc. consulting inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (CustomCode)
- (UIView *)findFirstResponder;
- (void)checkViews:(NSArray *)subviews;
@end

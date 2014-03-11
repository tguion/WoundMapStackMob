//
//  NSObject+performBlockAfterDelay.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/11/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "NSObject+performBlockAfterDelay.h"

@implementation NSObject (performBlockAfterDelay)

- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}
@end

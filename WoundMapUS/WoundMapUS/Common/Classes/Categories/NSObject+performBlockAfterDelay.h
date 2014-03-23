//
//  NSObject+performBlockAfterDelay.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/11/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//
//  https://github.com/Shmoopi/iOS-System-Services/blob/master/System%20Services/Utilities/NSObject%2BPerformBlockAfterDelay.h

#import <Foundation/Foundation.h>

@interface NSObject (performBlockAfterDelay)

- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay;

@end

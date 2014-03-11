//
//  NSObject+performBlockAfterDelay.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/11/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (performBlockAfterDelay)

- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay;

@end

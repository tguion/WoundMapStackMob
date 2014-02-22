//
//  WMNavigationCoordinator_iPad.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/22/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMNavigationCoordinator_iPad.h"

@implementation WMNavigationCoordinator_iPad

+ (WMNavigationCoordinator_iPad *)sharedInstance
{
    static WMNavigationCoordinator_iPad *_SharedInstance = nil;
    if (nil == _SharedInstance) {
        _SharedInstance = [[WMNavigationCoordinator_iPad alloc] init];
    }
    return _SharedInstance;
}

@end

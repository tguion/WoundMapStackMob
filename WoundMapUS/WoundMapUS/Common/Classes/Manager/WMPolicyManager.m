//
//  WMPolicyManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPolicyManager.h"

@implementation WMPolicyManager

+ (WMPolicyManager *)sharedInstance
{
    static WMPolicyManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMPolicyManager alloc] init];
    });
    return SharedInstance;
}

@end

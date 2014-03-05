//
//  WMPhotoManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPhotoManager.h"

extern NSString *const kTaskDidCompleteNotification;

@implementation WMPhotoManager

+ (WMPhotoManager *)sharedInstance
{
    static WMPhotoManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMPhotoManager alloc] init];
    });
    return SharedInstance;
}

@end

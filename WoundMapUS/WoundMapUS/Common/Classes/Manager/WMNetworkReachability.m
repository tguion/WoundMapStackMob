//
//  WMNetworkReachability.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/6/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMNetworkReachability.h"

NSString * WMNetworkStatusDidChangeNotification = @"WMNetworkStatusDidChangeNotification";
NSString * WMCurrentNetworkStatusKey = @"WMCurrentNetworkStatusKey";

typedef void (^WMNetworkStatusBlock)(WMNetworkStatus status);

@interface WMNetworkReachability ()

@property (nonatomic) int networkStatus;
@property (readwrite, nonatomic, copy) WMNetworkStatusBlock localNetworkStatusBlock;

- (void)addNetworkStatusDidChangeObserver;
- (void)removeNetworkStatusDidChangeObserver;
- (void)networkChangeNotificationFromAFNetworking:(NSNotification *)notification;

@end

@implementation WMNetworkReachability

+ (WMNetworkReachability *)sharedInstance
{
    static WMNetworkReachability *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMNetworkReachability alloc] init];
    });
    return SharedInstance;
}

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://woundmapus.fatfractal.com"]];
    
    if (self) {
        self.networkStatus = -1;
        self.localNetworkStatusBlock = nil;
        [self addNetworkStatusDidChangeObserver];
    }
    
    return self;
}

- (WMNetworkStatus)currentNetworkStatus
{
    return self.networkStatus;
}

- (void)addNetworkStatusDidChangeObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChangeNotificationFromAFNetworking:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)removeNetworkStatusDidChangeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)setNetworkStatusChangeBlock:(void (^)(WMNetworkStatus))block
{
    self.localNetworkStatusBlock = block;
}

- (void)networkChangeNotificationFromAFNetworking:(NSNotification *)notification
{
    int notificationNetworkStatus = [self translateAFNetworkingStatus:[[[notification userInfo] objectForKey:AFNetworkingReachabilityNotificationStatusItem] intValue]];
    
    if (self.networkStatus != notificationNetworkStatus) {
        self.networkStatus = notificationNetworkStatus;
        if (self.localNetworkStatusBlock) {
            self.localNetworkStatusBlock(self.networkStatus);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:WMNetworkStatusDidChangeNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.currentNetworkStatus], WMCurrentNetworkStatusKey, nil]];
    }
    
}

- (WMNetworkStatus)translateAFNetworkingStatus:(AFNetworkReachabilityStatus)status
{
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return WMNetworkStatusReachable;
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return WMNetworkStatusNotReachable;
            break;
        case AFNetworkReachabilityStatusUnknown:
            return WMNetworkStatusUnknown;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return WMNetworkStatusReachable;
            break;
        default:
            return WMNetworkStatusUnknown;
            break;
    }
}

- (void)dealloc
{
    [self removeNetworkStatusDidChangeObserver];
}

@end

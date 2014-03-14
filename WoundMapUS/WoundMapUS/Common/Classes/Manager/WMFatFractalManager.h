//
//  WMFatFractalManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FFEF/FatFractal.h>

@class WMParticipant;

@interface WMFatFractalManager : NSObject

+ (WMFatFractalManager *)sharedInstance;

// simple login alert shown when execution occurs with user session timeout
- (void)showLoginWithTitle:(NSString *)title andMessage:(NSString *)message;

- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext;

- (void)fetchCollection:(NSString *)collection
                  query:(NSString *)query
   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
             onComplete:(FFHttpMethodCompletion)onComplete;

- (void)registerParticipant:(WMParticipant *)participant password:(NSString *)password completionHandler:(void (^)(NSError *))handler;

- (void)clearOperationCache;
- (void)submitOperationsToQueue;

@end

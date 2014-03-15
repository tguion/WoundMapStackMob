//
//  WMFatFractalManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FFEF/FatFractal.h>

typedef void (^WMOperationCallback)(NSError *error, NSManagedObject *object, BOOL signInRequired);

@class WMFatFractal;
@class WMParticipant, WMPatient;

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
- (void)addParticipantToTeam:(WMParticipant *)participant;

- (void)createPatient:(WMPatient *)patient;

- (void)updateObject:(NSManagedObject *)object ff:(WMFatFractal *)ff block:(WMOperationCallback)block;
- (void)deleteObject:(NSManagedObject *)object ff:(WMFatFractal *)ff block:(WMOperationCallback)block;

- (void)clearOperationCache;
- (void)submitOperationsToQueue;

@end

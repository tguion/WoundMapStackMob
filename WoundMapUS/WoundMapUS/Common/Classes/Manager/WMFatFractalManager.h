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
@class WMTeamInvitation, WMTeam;

@interface WMFatFractalManager : NSObject

+ (WMFatFractalManager *)sharedInstance;

// simple login alert shown when execution occurs with user session timeout
- (void)showLoginWithTitle:(NSString *)title andMessage:(NSString *)message;

- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext ff:(WMFatFractal *)ff completionHandler:(FFHttpMethodCompletion)completionHandler;

- (void)fetchCollection:(NSString *)collection
                  query:(NSString *)query
                     ff:(WMFatFractal *)ff
   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
      completionHandler:(FFHttpMethodCompletion)completionHandler;

- (void)registerParticipant:(WMParticipant *)participant password:(NSString *)password completionHandler:(void (^)(NSError *))completionHandler;
- (void)createParticipant:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler;
- (void)createTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler;
- (void)createTeamWithParticipant:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler;
- (void)addParticipantToTeam:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler;

- (void)createPatient:(WMPatient *)patient;

- (void)createObject:(id)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler;
- (void)updateObject:(NSManagedObject *)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler;
- (void)deleteObject:(NSManagedObject *)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler;
- (void)loadBlobs:(id)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler;

@property (readonly, nonatomic) BOOL isCacheEmpty;
- (void)clearOperationCache;
- (void)submitOperationsToQueue;

@end

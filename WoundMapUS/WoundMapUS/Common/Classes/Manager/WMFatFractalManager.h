//
//  WMFatFractalManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WMOperationCallback)(NSError *error, id object, BOOL signInRequired);
typedef void (^WMErrorCallback)(NSError *error);
typedef void (^WMObjectCallback)(NSError *error, id object);
typedef void (^WMAddToGrabBagBlock)(id item, id aggregator, NSString *grabBagName);

@class WMFatFractal;
@class WMParticipant, WMPatient, WMPerson;
@class WMTeamInvitation, WMTeam;

@interface WMFatFractalManager : NSObject <FFQueueDelegate>

+ (WMFatFractalManager *)sharedInstance;

// simple login alert shown when execution occurs with user session timeout
- (void)showLoginWithTitle:(NSString *)title andMessage:(NSString *)message;

- (void)processUpdatesAndDeletes;

- (void)updateParticipant:(WMParticipant *)participant completionHandler:(WMErrorCallback)completionHandler;
- (void)acquireParticipantForUser:(FFUser *)user  completionHandler:(WMObjectCallback)completionHandler;
- (void)updateTeam:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(WMObjectCallback)completionHandler;
- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)acquireGrabBagsForObjects:(NSArray *)objects aliases:(NSSet *)aliases ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;

- (void)fetchCollection:(NSString *)collection
                  query:(NSString *)query
                depthGb:(NSInteger)depthGb
               depthRef:(NSInteger)depthRef
                     ff:(WMFatFractal *)ff
   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
      completionHandler:(FFHttpMethodCompletion)completionHandler;

- (void)createParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)updateParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)createPerson:(WMPerson *)person ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)createTeamWithParticipant:(WMParticipant *)participant user:(id<FFUserProtocol>)user ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)createTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)revokeTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)addParticipantToTeamFromTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)removeParticipantFromTeam:(WMParticipant *)teamMember ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;

- (void)createPatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMObjectCallback)completionHandler;
- (void)updatePatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;


- (void)deletePatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;

@end

//
//  WMFatFractalManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/13/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const kNumberFreeMonthsFirstSubscription;

typedef void (^WMOperationCallback)(NSError *error, id object, BOOL signInRequired);
typedef void (^WMErrorCallback)(NSError *error);
typedef void (^WMObjectCallback)(NSError *error, id object);
typedef void (^WMObjectsCallback)(NSError *error, id object0, id object1);

@class WMFatFractal;
@class WMParticipant, WMPatient, WMPerson, WMOrganization;
@class WMTeamInvitation, WMTeam, WMTeamPolicy;
@class WMWoundPhoto, WMPhoto;

@interface WMFatFractalManager : NSObject <FFQueueDelegate>

+ (WMFatFractalManager *)sharedInstance;

@property (nonatomic) BOOL processUpdatesOnNSManagedObjectContextObjectsDidChangeNotification;
@property (nonatomic) BOOL processDeletesOnNSManagedObjectContextObjectsDidChangeNotification;

// simple login alert shown when execution occurs with user session timeout
- (void)showLoginWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)truncateStoreForSignIn:(WMParticipant *)participant completionHandler:(dispatch_block_t)completionHandler;

- (void)updateParticipant:(WMParticipant *)participant completionHandler:(WMErrorCallback)completionHandler;
- (void)acquireParticipantForUser:(FFUser *)user  completionHandler:(WMObjectCallback)completionHandler;
- (void)fetchPatients:(NSManagedObjectContext *)managedObjectContext ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)updateGrabBags:(NSArray *)grabBagNames aggregator:(NSManagedObject *)aggregator ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;

- (void)createParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)updateParticipantAfterRegistration:(WMParticipant *)participant ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)updatePerson:(WMPerson *)person ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)updateOrganization:(WMOrganization *)organization ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)createTeamWithParticipant:(WMParticipant *)participant user:(id<FFUserProtocol>)user ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)createTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)revokeTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)addParticipantToTeamFromTeamInvitation:(WMTeamInvitation *)teamInvitation team:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)removeParticipant:(WMParticipant *)teamMember fromTeam:(WMTeam *)team ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)movePatientsForParticipant:(WMParticipant *)participant toTeam:(WMTeam *)team completionHandler:(WMErrorCallback)completionHandler;

- (void)queueUploadPhotosForWoundPhoto:(WMWoundPhoto *)woundPhoto photo:(WMPhoto *)photo;
- (void)uploadPhotosForWoundPhoto:(WMWoundPhoto *)woundPhoto photo:(WMPhoto *)photo;

- (void)createPatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMObjectCallback)completionHandler;
- (void)updatePatient:(WMPatient *)patient ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;

- (BOOL)updateTelecomType:(WMFatFractal *)ff managedObjectContext:(NSManagedObjectContext *)managedObjectContext completionHandler:(FFHttpMethodCompletion)completionHandler;
- (BOOL)updateMedication:(WMFatFractal *)ff managedObjectContext:(NSManagedObjectContext *)managedObjectContext completionHandler:(FFHttpMethodCompletion)completionHandler;

- (NSInteger)deleteExpiredPhotos:(WMTeamPolicy *)teamPolicy;
- (void)deletePhotosForPatient:(WMPatient *)patient;

- (void)decrementPatientEncounterCreditForPatient:(WMPatient *)patient onComplete:(dispatch_block_t)onComplete;

@end

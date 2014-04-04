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

@class WMFatFractal;
@class WMParticipant, WMPatient;
@class WMTeamInvitation, WMTeam;

@interface WMFatFractalManager : NSObject

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

- (void)createParticipant:(NSManagedObjectID *)participantObjectID ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler;
- (void)createTeamWithParticipant:(WMParticipant *)participant user:(id<FFUserProtocol>)user ff:(WMFatFractal *)ff completionHandler:(WMErrorCallback)completionHandler;
- (void)createTeamInvitation:(WMTeamInvitation *)teamInvitation ff:(WMFatFractal *)ff completionHandler:(void (^)(NSError *))completionHandler;

- (void)createPatient:(WMPatient *)patient ff:(WMFatFractal *)ff;
- (void)updatePatient:(WMPatient *)patient insertedObjectIDs:(NSArray *)insertedObjectIDs updatedObjectIDs:(NSArray *)updatedObjectIDs ff:(WMFatFractal *)ff;

- (NSBlockOperation *)createObject:(id)object
                             ffUrl:(NSString *)ffUrl
                                ff:(WMFatFractal *)ff
                        addToQueue:(BOOL)addToQueue
                 completionHandler:(WMOperationCallback)completionHandler;

- (NSBlockOperation *)createObject:(id)object
                             ffUrl:(NSString *)ffUrl
                                ff:(WMFatFractal *)ff
                        addToQueue:(BOOL)addToQueue
                      insertAtHead:(BOOL)insertAtHead
                 completionHandler:(WMOperationCallback)completionHandler;

- (NSBlockOperation *)createArray:(NSArray *)objectIDs
                       collection:(NSString *)collection
                               ff:(WMFatFractal *)ff
                       addToQueue:(BOOL)addToQueue
                 reverseEnumerate:(BOOL)reverseEnumerate
                completionHandler:(void (^)(NSError *))completionHandler;

- (NSBlockOperation *)createArray:(NSArray *)objectIDs
                       collection:(NSString *)collection
                               ff:(WMFatFractal *)ff
                       addToQueue:(BOOL)addToQueue
                completionHandler:(void (^)(NSError *))completionHandler;

- (NSBlockOperation *)updateObject:(NSManagedObject *)object ff:(WMFatFractal *)ff addToQueue:(BOOL)addToQueue completionHandler:(WMOperationCallback)completionHandler;
- (NSBlockOperation *)deleteObject:(NSManagedObject *)object ff:(WMFatFractal *)ff addToQueue:(BOOL)addToQueue completionHandler:(WMOperationCallback)completionHandler;
- (NSBlockOperation *)loadBlobs:(id)object ff:(WMFatFractal *)ff completionHandler:(WMOperationCallback)completionHandler;

- (NSBlockOperation *)grabBagAdd:(NSManagedObjectID *)itemObjectID
                              to:(NSManagedObjectID *)objectObjectID
                     grabBagName:(NSString *)name
                              ff:(WMFatFractal *)ff
                      addToQueue:(BOOL)addToQueue;
- (NSBlockOperation *)grabBagRemove:(NSManagedObjectID *)itemObjectID
                                 to:(NSManagedObjectID *)objectObjectID
                        grabBagName:(NSString *)name
                                 ff:(WMFatFractal *)ff
                         addToQueue:(BOOL)addToQueue;

@property (readonly, nonatomic) BOOL isCacheEmpty;
- (void)clearOperationCache;
- (void)submitOperationsToQueue;

@end

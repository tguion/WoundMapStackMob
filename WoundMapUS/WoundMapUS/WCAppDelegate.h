//
//  WCAppDelegate.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "CoreDataHelper.h"

extern NSString * const kPatientReferralNotification;
extern NSString * const kTeamInvitationNotification;
extern NSString * const kTeamMemberAddedNotification;

@class KeychainItemWrapper;
@class WMFatFractal;
@class WMNavigationCoordinator;
@class WMParticipant, WMNavigationTrack;

@interface WCAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

+ (KeychainItemWrapper *)keychainItem;
+ (BOOL)checkForAuthentication;

@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) UINavigationController *initialViewController;

@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;
//@property (readonly, strong, nonatomic) WMFatFractal *ff;
@property (nonatomic, readonly) WMNavigationCoordinator *navigationCoordinator;

@property (nonatomic, readonly) NSURL *applicationDocumentsDirectory;

@property (nonatomic, strong) WMParticipant *participant;           // clinician using the app
@property (nonatomic, strong) NSDictionary *patient2StageMap;       // used to move patients to team

- (void)signOut;
- (void)handleFatFractalSignout;

- (void)downloadFFDataForCollection:(NSDictionary *)map fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler;

@end

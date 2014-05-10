//
//  WCAppDelegate.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "CoreDataHelper.h"

@class KeychainItemWrapper;
@class WMFatFractal;
@class WMNavigationCoordinator;
@class WMParticipant, WMNavigationTrack;

@interface WCAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

+ (KeychainItemWrapper *)keychainItem;
+ (BOOL)checkForAuthentication;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;
@property (readonly, strong, nonatomic) WMFatFractal *ff;
@property (nonatomic, readonly) WMNavigationCoordinator *navigationCoordinator;

@property (nonatomic, readonly) NSURL *applicationDocumentsDirectory;

@property (nonatomic, strong) WMParticipant *participant;           // clinician using the app

- (void)signOut;

@end

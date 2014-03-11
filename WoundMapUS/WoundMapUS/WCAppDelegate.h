//
//  WCAppDelegate.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "CoreDataHelper.h"
#import <FFEF/FatFractal.h>

@class WMFatFractal;
@class WMNavigationCoordinator;
@class WMParticipant, User;

@interface WMFatFractal : FatFractal

+ (WMFatFractal *)sharedInstance;

@end

@interface WCAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;
@property (readonly, strong, nonatomic) WMFatFractal *ff;
@property (nonatomic, readonly) WMNavigationCoordinator *navigationCoordinator;

@property (nonatomic, strong) WMParticipant *participant;   // clinician using the app

@end

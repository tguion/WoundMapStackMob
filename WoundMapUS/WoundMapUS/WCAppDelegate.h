//
//  WCAppDelegate.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "CoreDataHelper.h"

@class WMParticipant, User, WMPatient;

@interface WCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;
@property (nonatomic, strong) WMParticipant *participant;   // clinician using the app
@property (nonatomic, strong) NSString *stackMobUsername;   // logged team in StackMob

@property (strong, nonatomic) WMPatient *patient;           // active patient

@end

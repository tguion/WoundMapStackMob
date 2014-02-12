//
//  WCAppDelegate.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "CoreDataHelper.h"

@class User;

@interface WCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;
@property (nonatomic, strong) User *user;    // user logged into StackMob

@end

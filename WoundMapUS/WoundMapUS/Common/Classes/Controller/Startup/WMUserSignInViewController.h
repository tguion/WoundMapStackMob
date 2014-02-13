//
//  WMUserSignInViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class User;
@class WMUserSignInViewController;

@protocol UserSignInDelegate <NSObject>

- (void)userSignInViewController:(WMUserSignInViewController *)viewController didSignInUser:(User *)user;
- (void)userSignInViewControllerDidCancel:(WMUserSignInViewController *)viewController;

@end

@interface WMUserSignInViewController : WMBaseViewController

@property (nonatomic, weak) id<UserSignInDelegate> delegate;

@property (nonatomic) BOOL createNewUserFlag;
@property (strong, nonatomic) User *selectedUser;

@end

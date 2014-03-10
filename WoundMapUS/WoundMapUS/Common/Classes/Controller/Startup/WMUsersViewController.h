//
//  WMUsersViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMUserSignInViewController.h"

@class WMParticipant;

@interface WMUsersViewController : WMBaseViewController

@property (nonatomic, weak) id<UserSignInDelegate> delegate;
@property (strong, nonatomic) WMParticipant *selectedParticipant;

@end

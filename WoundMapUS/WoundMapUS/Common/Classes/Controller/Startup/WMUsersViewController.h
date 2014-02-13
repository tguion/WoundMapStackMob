//
//  WMUsersViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMUserSignInViewController.h"

// TODO use WMBaseViewController

@interface WMUsersViewController : UITableViewController

@property (nonatomic, weak) id<UserSignInDelegate> delegate;
@property (strong, nonatomic) User *selectedUser;

@end

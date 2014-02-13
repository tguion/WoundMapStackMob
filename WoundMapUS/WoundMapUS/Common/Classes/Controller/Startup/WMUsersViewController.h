//
//  WMUsersViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMUserSignInViewController.h"

@interface WMUsersViewController : UITableViewController

@property (nonatomic, weak) id<UserSignInDelegate> delegate;
@property (strong, nonatomic) User *selectedUser;

@end

//
//  WMManageTeamViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 4/6/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMManageTeamViewController;

@protocol ManageTeamViewControllerDelegate <NSObject>

- (void)manageTeamViewControllerDidFinish:(WMManageTeamViewController *)viewController;
- (void)manageTeamViewControllerDidCancel:(WMManageTeamViewController *)viewController;

@end

@interface WMManageTeamViewController : WMBaseViewController

@property (weak, nonatomic) id<ManageTeamViewControllerDelegate> delegate;

@end

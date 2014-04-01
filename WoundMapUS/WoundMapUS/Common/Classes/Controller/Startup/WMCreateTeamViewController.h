//
//  WMCreateTeamViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 4/1/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMCreateTeamViewController;
@class WMTeam;

@protocol CreateTeamViewControllerDelegate <NSObject>

- (void)createTeamViewController:(WMCreateTeamViewController *)viewController didCreateTeam:(WMTeam *)team;
- (void)createTeamViewControllerDidCancel:(WMCreateTeamViewController *)viewController;

@end

@interface WMCreateTeamViewController : WMBaseViewController

@property (weak, nonatomic) id<CreateTeamViewControllerDelegate> delegate;
@property (strong, nonatomic) WMTeam *team;

@end

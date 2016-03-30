//
//  WMCreateTeamInvitationViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 4/2/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMCreateTeamInvitationViewController;
@class WMTeamInvitation;

@protocol CreateTeamInvitationViewControllerDelegate <NSObject>

- (void)createTeamInvitationViewController:(WMCreateTeamInvitationViewController *)viewController didCreateInvitation:(WMTeamInvitation *)teamInvitation;
- (void)createTeamInvitationViewControllerDidCancel:(WMCreateTeamInvitationViewController *)viewController;

@end

@interface WMCreateTeamInvitationViewController : WMBaseViewController

@property (weak,nonatomic) id<CreateTeamInvitationViewControllerDelegate> delegate;
@property (strong, nonatomic) WMTeamInvitation *teamInvitation;

@end

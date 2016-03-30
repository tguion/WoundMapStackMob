//
//  WMIAPJoinTeamViewController.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/16/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMIAPJoinTeamViewController;
@class WMTeamInvitation;

@protocol WMIAPJoinTeamViewControllerDelegate <NSObject>

- (void)iapJoinTeamViewControllerDidPurchase:(WMIAPJoinTeamViewController *)viewController;
- (void)iapJoinTeamViewControllerDidDecline:(WMIAPJoinTeamViewController *)viewController;

@end

@interface WMIAPJoinTeamViewController : UIViewController

@property (weak, nonatomic) id<WMIAPJoinTeamViewControllerDelegate> delegate;

@property (strong, nonatomic) WMTeamInvitation *teamInvitation;

@end

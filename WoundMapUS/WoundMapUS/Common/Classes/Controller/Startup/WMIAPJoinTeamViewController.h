//
//  WMIAPJoinTeamViewController.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMIAPJoinTeamViewController;

@protocol WMIAPJoinTeamViewControllerDelegate <NSObject>

- (void)iapJoinTeamViewControllerDidPurchase:(WMIAPJoinTeamViewController *)viewController;
- (void)iapJoinTeamViewControllerDidDecline:(WMIAPJoinTeamViewController *)viewController;

@end

@interface WMIAPJoinTeamViewController : UIViewController

@property (weak, nonatomic) id<WMIAPJoinTeamViewControllerDelegate> delegate;

@end

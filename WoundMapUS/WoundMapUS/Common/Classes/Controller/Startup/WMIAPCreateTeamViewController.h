//
//  WMIAPCreateTeamViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMIAPCreateTeamViewController;

@protocol IAPCreateTeamViewControllerDelegate <NSObject>

- (void)iapCreateTeamViewControllerDidPurchase:(WMIAPCreateTeamViewController *)viewController;
- (void)iapCreateTeamViewControllerDidDecline:(WMIAPCreateTeamViewController *)viewController;

@end

@interface WMIAPCreateTeamViewController : UIViewController

@property (weak, nonatomic) id<IAPCreateTeamViewControllerDelegate> delegate;

@end

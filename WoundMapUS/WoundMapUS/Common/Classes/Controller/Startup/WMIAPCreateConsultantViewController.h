//
//  WMIAPCreateConsultantViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/19/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMIAPCreateConsultantViewController;

@protocol IAPCreateConsultantViewControllerDelegate <NSObject>

- (void)iapCreateConsultantViewControllerDidPurchase:(WMIAPCreateConsultantViewController *)viewController;
- (void)iapCreateConsultantViewControllerDidDecline:(WMIAPCreateConsultantViewController *)viewController;

@end

@interface WMIAPCreateConsultantViewController : UIViewController

@property (weak, nonatomic) id<IAPCreateConsultantViewControllerDelegate> delegate;

@end

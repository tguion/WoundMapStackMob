//
//  WMCreateConsultingGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 4/29/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMCreateConsultingGroupViewController;

@protocol IAPCreateConsultantViewControllerDelegate <NSObject>

- (void)createConsultantViewControllerDidPurchase:(WMCreateConsultingGroupViewController *)viewController;
- (void)createConsultantViewControllerDidDecline:(WMCreateConsultingGroupViewController *)viewController;

@end

@interface WMCreateConsultingGroupViewController : WMBaseViewController

@property (weak, nonatomic) id<IAPCreateConsultantViewControllerDelegate> delegate;

@end

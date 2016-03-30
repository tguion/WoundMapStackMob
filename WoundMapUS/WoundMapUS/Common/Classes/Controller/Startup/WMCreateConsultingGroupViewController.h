//
//  WMCreateConsultingGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 4/29/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMCreateConsultingGroupViewController;

@protocol IAPCreateConsultantViewControllerDelegate <NSObject>

- (void)createConsultantViewControllerDidFinish:(WMCreateConsultingGroupViewController *)viewController;
- (void)createConsultantViewControllerDidCancel:(WMCreateConsultingGroupViewController *)viewController;

@end

@interface WMCreateConsultingGroupViewController : WMBaseViewController

@property (weak, nonatomic) id<IAPCreateConsultantViewControllerDelegate> delegate;

@end

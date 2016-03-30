//
//  WMSelectWoundViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSelectWoundViewController;
@class WMWound;

@protocol SelectWoundViewControllerDelegate <NSObject>

- (void)selectWoundController:(WMSelectWoundViewController *)viewController didSelectWound:(WMWound *)wound;
- (void)selectWoundControllerDidCancel:(WMSelectWoundViewController *)controller;

@end

@interface WMSelectWoundViewController : WMBaseViewController

@property (weak, nonatomic) id<SelectWoundViewControllerDelegate> delegate;

@end

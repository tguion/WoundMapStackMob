//
//  WMSelectWoundLocationViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSelectWoundLocationViewController;
@class WMWoundLocation;

@protocol SelectWoundLocationViewControllerDelegate <NSObject>

- (void)selectWoundLocationViewController:(WMSelectWoundLocationViewController *)viewController didSelectWoundLocation:(WMWoundLocation *)woundLocation;
- (void)selectWoundLocationViewControllerDidCancel:(WMSelectWoundLocationViewController *)viewController;

@end

@interface WMSelectWoundLocationViewController : WMBaseViewController

@property (weak, nonatomic) id<SelectWoundLocationViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWoundLocation *selectedWoundLocation;

@end

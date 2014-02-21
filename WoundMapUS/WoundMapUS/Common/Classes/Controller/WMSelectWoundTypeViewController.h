//
//  WMSelectWoundTypeViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSelectWoundTypeViewController;
@class WMWoundType;

@protocol SelectWoundTypeViewControllerDelegate <NSObject>

- (void)selectWoundTypeViewController:(WMSelectWoundTypeViewController *)viewController didSelectWoundType:(WMWoundType *)woundType;
- (void)selectWoundTypeViewControllerDidCancel:(WMSelectWoundTypeViewController *)viewController;

@end

@interface WMSelectWoundTypeViewController : WMBaseViewController

@property (weak, nonatomic) id<SelectWoundTypeViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWoundType *selectedWoundType;
@property (strong, nonatomic) WMWoundType *parentWoundType;

@end

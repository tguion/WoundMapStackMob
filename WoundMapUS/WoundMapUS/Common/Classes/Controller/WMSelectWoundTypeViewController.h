//
//  WMSelectWoundTypeViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMSelectWoundTypeViewController;
@class WMWoundType;

@protocol SelectWoundTypeViewControllerDelegate <NSObject>

- (void)selectWoundTypeViewController:(WMSelectWoundTypeViewController *)viewController didSelectWoundType:(WMWoundType *)woundType;
- (void)selectWoundTypeViewControllerDidCancel:(WMSelectWoundTypeViewController *)viewController;

@end

@interface WMSelectWoundTypeViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<SelectWoundTypeViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWound *wound;
@property (strong, nonatomic) WMWoundType *selectedWoundType;
@property (strong, nonatomic) WMWoundType *parentWoundType;

@end

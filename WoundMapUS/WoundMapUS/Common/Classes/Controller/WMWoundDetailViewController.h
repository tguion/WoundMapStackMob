//
//  WMWoundDetailViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMWound;
@class WMWoundDetailViewController, WMSelectWoundTypeViewController;

@protocol WoundDetailViewControllerDelegate <NSObject>

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didUpdateWound:(WMWound *)wound;
- (void)woundDetailViewControllerDidCancelUpdate:(WMWoundDetailViewController *)viewController;
- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didDeleteWound:(WMWound *)wound;

@end

@interface WMWoundDetailViewController : WMBaseViewController

@property (weak, nonatomic) id<WoundDetailViewControllerDelegate> delegate;

@property (nonatomic, getter = isNewWound) BOOL newWoundFlag;
@property (strong, nonatomic) WMWound *wound;

@end

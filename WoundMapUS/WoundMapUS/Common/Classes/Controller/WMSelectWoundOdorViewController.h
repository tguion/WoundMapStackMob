//
//  WMSelectWoundOdorViewController.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/26/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSelectWoundOdorViewController, WMWoundOdor;

@protocol SelectWoundOdorViewControllerDelegate <NSObject>

@property (weak, nonatomic) WMWoundOdor *selectedWoundOdor;

- (void)selectWoundOdorViewController:(WMSelectWoundOdorViewController *)viewController didSelectWoundOdor:(WMWoundOdor *)woundOdor;
- (void)selectWoundOdorViewControllerDidCancel:(WMSelectWoundOdorViewController *)viewController;

@end

@interface WMSelectWoundOdorViewController : WMBaseViewController

@property (weak, nonatomic) id<SelectWoundOdorViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWoundOdor *woundOdor;

@end

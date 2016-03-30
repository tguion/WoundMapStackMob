//
//  WMWoundTreatmentGroupsViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMWoundTreatmentGroupsViewController;

@protocol WoundTreatmentGroupsDelegate <NSObject>

- (void)woundTreatmentGroupsViewControllerDidFinish:(WMWoundTreatmentGroupsViewController *)viewController;
- (void)woundTreatmentGroupsViewControllerDidCancel:(WMWoundTreatmentGroupsViewController *)viewController;

@end

@interface WMWoundTreatmentGroupsViewController : WMBaseViewController

@property (weak, nonatomic) id<WoundTreatmentGroupsDelegate> delegate;

@end

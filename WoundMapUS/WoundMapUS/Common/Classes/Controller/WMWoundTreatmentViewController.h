//
//  WMWoundTreatmentViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMWoundTreatmentViewController;
@class WMWoundTreatmentGroup, WMWoundTreatment;

@protocol WoundTreatmentViewControllerDelegate <NSObject>

- (void)woundTreatmentViewController:(WMWoundTreatmentViewController *)viewController willDeleteWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup;
- (void)woundTreatmentViewControllerDidFinish:(WMWoundTreatmentViewController *)viewController;
- (void)woundTreatmentViewControllerDidCancel:(WMWoundTreatmentViewController *)viewController;

@end

@interface WMWoundTreatmentViewController : WMBaseViewController

@property (weak, nonatomic) id<WoundTreatmentViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWoundTreatmentGroup *woundTreatmentGroup;
@property (strong, nonatomic) WMWoundTreatment *parentWoundTreatment;

@end

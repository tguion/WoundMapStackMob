//
//  WMWoundTreatmentViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMWoundTreatmentViewController;
@class WMWoundTreatmentGroup, WMWoundTreatment;

@protocol WoundTreatmentViewControllerDelegate <NSObject>

- (void)woundTreatmentViewController:(WMWoundTreatmentViewController *)viewController willDeleteWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup;
- (void)woundTreatmentViewControllerDidFinish:(WMWoundTreatmentViewController *)viewController;
- (void)woundTreatmentViewControllerDidCancel:(WMWoundTreatmentViewController *)viewController;

@end

@interface WMWoundTreatmentViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<WoundTreatmentViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWoundTreatmentGroup *woundTreatmentGroup;
@property (strong, nonatomic) WMWoundTreatment *parentWoundTreatment;

@end

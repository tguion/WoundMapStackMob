//
//  WMWoundMeasurementGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMWoundMeasurementGroupViewController, WMWoundMeasurementGroup, WMWoundMeasurement;

@protocol WoundMeasurementGroupViewControllerDelegate <NSObject>

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController;
- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController;

@end

@interface WMWoundMeasurementGroupViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<WoundMeasurementGroupViewControllerDelegate> delegate;

@property (strong, nonatomic) WMWoundMeasurementGroup *woundMeasurementGroup;       // associated with woundPhoto if possible
@property (strong, nonatomic) WMWoundMeasurement *parentWoundMeasurement;           // set when navigating to children woundMeasurements

@end

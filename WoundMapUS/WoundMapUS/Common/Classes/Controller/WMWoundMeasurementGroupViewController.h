//
//  WMWoundMeasurementGroupViewController.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/25/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMWoundMeasurementGroupViewController, WMWoundPhoto, WMWoundMeasurementGroup, WMWoundMeasurement;

@protocol WoundMeasurementGroupViewControllerDelegate <NSObject>

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController;
- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController;

@end

@interface WMWoundMeasurementGroupViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<WoundMeasurementGroupViewControllerDelegate> delegate;

@end

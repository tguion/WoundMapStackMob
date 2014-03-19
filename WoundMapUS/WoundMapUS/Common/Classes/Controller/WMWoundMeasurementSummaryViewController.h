//
//  WMWoundMeasurementSummaryViewController.h
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

@class WMWound, WMWoundMeasurementGroup;

@interface WMWoundMeasurementSummaryViewController : UIViewController

@property (strong, nonatomic) WMWoundMeasurementGroup *woundMeasurementGroup;
@property (strong, nonatomic) WMWound *selectedWound;

@end

//
//  WMDevicesSummaryViewController.h
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

@class WMDeviceGroup;

@interface WMDevicesSummaryViewController : UIViewController

@property (strong, nonatomic) WMDeviceGroup *devicesGroup;
@property (nonatomic) BOOL drawFullHistory;

@end

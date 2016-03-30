//
//  WMPlotConfigureGraphViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMSimpleTableViewController.h"
#import "WMPlotSelectDatasetViewController.h"

@interface WMPlotConfigureGraphViewController : WMSimpleTableViewController

@property (weak, nonatomic) id<PlotViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *woundStatusMeasurementTitle;
@property (strong, nonatomic) NSMutableDictionary *wountStatusMeasurementTitle2RollupByKeyMapMap;

@end

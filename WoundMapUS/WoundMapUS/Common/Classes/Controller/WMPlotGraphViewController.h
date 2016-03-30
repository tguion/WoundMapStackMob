//
//  WMPlotGraphViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMPlotSelectDatasetViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface WMPlotGraphViewController : UIViewController <CPTPlotSpaceDelegate, CPTScatterPlotDelegate>

@property (weak, nonatomic) id<PlotViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *woundStatusMeasurementTitle;
@property (strong, nonatomic) NSArray *woundStatusMeasurementRollups;
@property (strong, nonatomic) NSDate *dateStart;
@property (strong, nonatomic) NSDate *dateEnd;

@end

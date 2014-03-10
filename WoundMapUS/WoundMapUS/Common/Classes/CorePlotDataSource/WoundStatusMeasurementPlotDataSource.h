//
//  WoundStatusMeasurementPlotDataSource.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/8/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"

@class WoundStatusMeasurementRollup;

@interface WoundStatusMeasurementPlotDataSource : NSObject <CPTScatterPlotDataSource>

@property (strong, nonatomic) WoundStatusMeasurementRollup *woundStatusMeasurementRollup;

@end

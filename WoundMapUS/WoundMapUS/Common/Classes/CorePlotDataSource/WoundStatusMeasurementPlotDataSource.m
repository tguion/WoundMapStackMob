//
//  WoundStatusMeasurementPlotDataSource.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/8/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WoundStatusMeasurementPlotDataSource.h"
#import "WoundStatusMeasurementRollup.h"

@implementation WoundStatusMeasurementPlotDataSource

@synthesize woundStatusMeasurementRollup=_woundStatusMeasurementRollup;

#pragma mark - CPTPlotDataSource

/// @name Data Values
/// @{

/** @brief @required The number of data points for the plot.
 *  @param plot The plot.
 *  @return The number of data points for the plot.
 **/
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return _woundStatusMeasurementRollup.valueCount;
}

/** @brief @optional Gets a plot data value for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param idx The data index of interest.
 *  @return A data point.
 **/
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return [[_woundStatusMeasurementRollup.data objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
	return _woundStatusMeasurementRollup.key;
}

@end

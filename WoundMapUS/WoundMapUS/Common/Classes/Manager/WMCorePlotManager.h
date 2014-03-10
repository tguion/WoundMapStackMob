//
//  WMCorePlotManager.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/3/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

extern NSInteger kXOffset; // emperical offset to place data to right of y-axis

@class WMWound;
@class CPTGraphHostingView, CPTXYGraph;
@protocol CPTPlotDataSource;

@protocol WCPlotDataSource <CPTPlotDataSource>

- (void)configureGraph:(CPTXYGraph *)graph;

@end

@interface WMCorePlotManager : NSObject

+ (WMCorePlotManager *)sharedInstance;

- (NSMutableDictionary *)wountStatusMeasurementTitle2RollupByKeyMapMapForWound:(WMWound *)wound graphableMeasurementTitles:(NSArray *)graphableMeasurementTitles;

@end
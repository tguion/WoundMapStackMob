//
//  PDFRenderer.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/26/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "PDFRenderer.h"
#import "WCPatient+Custom.h"
#import "WCBradenScale+Custom.h"
#import "WCWound+Custom.h"
#import "WCWoundPhoto+Custom.h"
#import "WCPhoto+Custom.h"
#import "WCWoundMeasurementGroup+Custom.h"
#import "WCWoundMeasurementGroup+CoreText.h"
#import "WCWoundMeasurement+Custom.h"
#import "WCWoundMeasurementValue+Custom.h"
#import "WCWoundTreatment+Custom.h"
#import "WCWoundTreatmentGroup+CoreText.h"
#import "WCWoundTreatmentValue+Custom.h"
#import "WCWoundTreatmentGroup+Custom.h"
#import "WCMedicationGroup+Custom.h"
#import "WCMedicationCategory+Custom.h"
#import "WCMedication+Custom.h"
#import "WCDeviceGroup+Custom.h"
#import "WCDeviceCategory+Custom.h"
#import "WCDeviceValue+Custom.h"
#import "WCDevice+Custom.h"
#import "WCPsychoSocialGroup+Custom.h"
#import "WCPsychoSocialItem+Custom.h"
#import "WCPsychoSocialValue+Custom.h"
#import "WCSkinAssessmentGroup+Custom.h"
#import "WCSkinAssessmentValue+Custom.h"
#import "WCSkinAssessmentCategory+Custom.h"
#import "WCSkinAssessment+Custom.h"
#import "WCCarePlanCategory+Custom.h"
#import "WCCarePlanGroup+CoreText.h"
#import "WCCarePlanGroup+Custom.h"
#import "WCCarePlanValue+Custom.h"
#import "WCCarePlanItem+Custom.h"
#import "WoundStatusMeasurementRollup.h"
#import "WoundStatusMeasurementPlotDataSource.h"
#import "PrintConfiguration.h"
#import "CorePlotManager.h"
#import "LocalStoreManager.h"
#import "UserDefaultsManager.h"
#import "DocumentManager.h"
#import "WCAppDelegate.h"
#import "WCUtilities.h"

NSInteger kXPlotOffset = 0;

@interface PDFRenderer ()

@property (strong, nonatomic) NSMutableDictionary *objectID2AttributedStringMap;

- (void)clearDataCache;

@property (strong, nonatomic) UIFont *tinyFont;
@property (strong, nonatomic) UIFont *smallFont;
@property (strong, nonatomic) UIFont *boldSmallFont;
@property (strong, nonatomic) UIFont *normalFont;

@property (readonly, nonatomic) NSDictionary *tinyAttributes;
@property (readonly, nonatomic) NSDictionary *smallAttributes;
@property (readonly, nonatomic) NSDictionary *smallCenteredAttributes;
@property (readonly, nonatomic) NSDictionary *boldSmallAttributes;
@property (readonly, nonatomic) NSDictionary *boldSmallCenteredAttributes;
@property (readonly, nonatomic) NSDictionary *normalAttributes;
@property (readonly, nonatomic) NSDictionary *normalCenteredAttributes;
@property (readonly, nonatomic) NSDictionary *italicsAttributes;

@property (readonly, nonatomic) CPTXYGraph *hostedGraph;                // hosted graph in hostingView

// all graphable keys in woundStatusMeasurementTitle, e.g. Irregular when woundStatusMeasurementTitle is Margins/Edges
// WoundStatusMeasurementRollup instances extracted from wountStatusMeasurementTitle2RollupByKeyMapMap for current woundStatusMeasurementTitle
@property (strong, nonatomic) NSArray *woundStatusMeasurementRollups;   

@property (strong, nonatomic) NSArray *plotDataSources;                 // one for each WCWoundMeasurement
@property (strong, nonatomic) NSArray *dateStrings;                     // possible x-axis labels
@property (strong, nonatomic) NSDate *dateMinimum;                      // min date for all keys in plotDataSources
@property (strong, nonatomic) NSDate *dateMaximum;                      // max date for all keys in plotDataSources
@property (nonatomic) NSInteger minimumReferenceDayNumber;              // minimum day number since reference date to adjust x-values of data
@property (nonatomic) NSInteger maximumReferenceDayNumber;              // maximum day number since reference date
@property (nonatomic) CGFloat yMinimum;                                 // minimum possible value for data types
@property (nonatomic) CGFloat yMaximum;                                 // maximum possible value for data types
@property (nonatomic) CGFloat yMinimumValue;                            // minimum value of selected data
@property (nonatomic) CGFloat yMaximumValue;                            // maximum value of selected data
@property (readonly, nonatomic) BOOL isBradenScale;                     // determine if our current plot is Braden Scale
@property (strong, nonatomic) NSMutableDictionary *key2RollupMap;       // selected WCWoundMeasurement.title or Braden Scale data
@property (strong, nonatomic) NSArray *rollups;                         // sorted rollups
@property (strong, nonatomic) NSString *yUnits;                         // units of y-axis

@end

@interface PDFRenderer (PrivateMethods)

- (void)initPlot;
- (void)configureHost;
- (void)configureGraph;
- (void)configurePlots;
- (void)configureAxes;
- (void)configureLegend;

- (void)initBradenPlot;
- (void)configureBradenHost;
- (void)configureBradenGraph;
- (void)configureBradenPlots;
- (void)configureBradenAxes;

@end

@implementation PDFRenderer (PrivateMethods)

- (void)initPlot
{
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    if ([self.woundStatusMeasurementRollups count] > 1) {
        [self configureLegend];
    }
}

- (void)configureHost
{
	self.hostingView.allowPinchScaling = NO;
}

- (void)configureGraph
{
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
	self.hostingView.hostedGraph = graph;
	// 2 - Set graph title
	NSString *title = self.woundStatusMeasurementTitle;
	graph.title = title;
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor blackColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 11.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 16.0f);
	// 4 - Set padding for plot area
    //	graph.paddingLeft = 0.0f;
    //	graph.paddingTop = 20.0f;
    //	graph.paddingRight = 0.0f;
    //	graph.paddingBottom = 0.0f;
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:30.0f];
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
}

- (void)configurePlots
{
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostingView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	// 2 - Create a plot for each dataSource - keep each dataSource
    // update data for reference date @min.
    for (WoundStatusMeasurementRollup *woundStatusMeasurementRollup in self.woundStatusMeasurementRollups) {
        DLog(@"%@.%@ BEFORE update: %@", woundStatusMeasurementRollup.title, woundStatusMeasurementRollup.key, [woundStatusMeasurementRollup description]);
        [woundStatusMeasurementRollup updateDataForReferenceDateDayNumber:self.minimumReferenceDayNumber];
        DLog(@"%@.%@ AFTER update: %@", woundStatusMeasurementRollup.title, woundStatusMeasurementRollup.key, [woundStatusMeasurementRollup description]);
    }
    NSMutableArray *dataSources = [[NSMutableArray alloc] initWithCapacity:[self.woundStatusMeasurementRollups count]];
    NSMutableArray *plots = [[NSMutableArray alloc] initWithCapacity:[self.woundStatusMeasurementRollups count]];
    for (WoundStatusMeasurementRollup *woundStatusMeasurementRollup in self.woundStatusMeasurementRollups) {
        if (woundStatusMeasurementRollup.valueCount < 2) {
            continue;
        }
        // else create a dataSource
        WoundStatusMeasurementPlotDataSource *dataSource = [[WoundStatusMeasurementPlotDataSource alloc] init];
        dataSource.woundStatusMeasurementRollup = woundStatusMeasurementRollup;
        [dataSources addObject:dataSource];
        // create plot
        CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
        plot.dataSource = dataSource;
        plot.delegate = self;
        plot.identifier = woundStatusMeasurementRollup.key;
        [graph addPlot:plot toPlotSpace:plotSpace];
        [plots addObject:plot];
    }
    self.plotDataSources = dataSources;
    // 3 - Set up plot space
	[plotSpace scaleToFitPlots:plots];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    xRange.location = CPTDecimalFromInteger(-kXPlotOffset);
    xRange.length = CPTDecimalAdd(CPTDecimalFromInteger(kXPlotOffset), CPTDecimalAdd(xRange.length, CPTDecimalFromFloat(0.25)));
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.05f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    yRange.length = CPTDecimalAdd(yRange.location, yRange.length);
    yRange.location = CPTDecimalFromFloat(self.yMinimum);
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    NSArray *colors = self.keyColors;
    NSArray *symbols = self.keySymbols;
    NSInteger index = 0;
    for (CPTScatterPlot *plot in plots) {
        CPTMutableLineStyle *lineStyle = [plot.dataLineStyle mutableCopy];
        lineStyle.lineWidth = 1.0;
        lineStyle.lineColor = [colors objectAtIndex:index];
        plot.dataLineStyle = lineStyle;
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [colors objectAtIndex:index];
        CPTPlotSymbol *symbol = [symbols objectAtIndex:index];
        symbol.fill = [CPTFill fillWithColor:[colors objectAtIndex:index]];
        symbol.lineStyle = symbolLineStyle;
        symbol.size = CGSizeMake(6.0f, 6.0f);
        plot.plotSymbol = symbol;
        ++index;
    }
}

- (void)configureAxes
{
    // 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blackColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 9.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 1.0f;
	axisLineStyle.lineColor = [CPTColor grayColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor blackColor];
	axisTextStyle.fontName = @"Helvetica-Bold";
	axisTextStyle.fontSize = 9.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor grayColor];
	tickLineStyle.lineWidth = 1.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor lightGrayColor];
	tickLineStyle.lineWidth = 1.0f;
	CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor lightGrayColor];
	tickLineStyle.lineWidth = 1.0f;
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostedGraph.axisSet;
	// 3 - Configure x-axis
	CPTXYAxis *x = axisSet.xAxis;
	x.title = @"Date";
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 16.0f;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 4.0f;
	x.minorTickLineStyle = axisLineStyle;
	x.minorTickLength = 2.0f;
	x.tickDirection = CPTSignNegative;
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(self.yMinimum);// CPTDecimalFromFloat(self.yMinimumValue);//CPTDecimalFromFloat(self.yMinimumValue * 0.9f);
    // build the labels and locations CPTAxis.-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber; maybe to determine which labels to skip
    CGFloat width = CGRectGetWidth(self.hostingView.bounds);
    CGFloat labelWidth = [@"00/00/00" sizeWithAttributes:self.boldSmallAttributes].width;
    NSInteger maximumLabelCount = width/labelWidth - 2;
    NSArray *dateStrings = self.dateStrings;
	CGFloat dateCount = [dateStrings count];
    NSInteger labelMod = dateCount/maximumLabelCount;
    if (labelMod == 0) {
        labelMod = 1;
    }
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xMinorLocations = [NSMutableSet setWithCapacity:dateCount];
	NSInteger location = 0;
    NSInteger index = 0;
	for (NSString *date in dateStrings) {
        if (index == 0 || (index % labelMod) > 0) {
			[xMinorLocations addObject:[NSNumber numberWithInteger:location]];
            ++location;
            ++index;
            continue;
        }
        // else
		CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date textStyle:x.labelTextStyle];
		label.tickLocation = CPTDecimalFromInteger(location);
		label.offset = x.majorTickLength;
		if (label) {
			[xLabels addObject:label];
			[xLocations addObject:[NSNumber numberWithInteger:location]];
		}
        ++location;
        ++index;
	}
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;
	x.minorTickLocations = xMinorLocations;
	// 4 - Configure y-axis
	CPTXYAxis *y = axisSet.yAxis;
    NSString *yUnits = self.yUnits;
	y.title = yUnits;
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -36.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 16.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLineStyle = axisLineStyle;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);//CPTDecimalFromInteger(-3);
    CGFloat yMaximum = self.yMaximum;
    if (0.0 == yMaximum) {
        // calculate self
        yMaximum = self.yMaximumValue * 1.2f;
    }
	NSInteger majorIncrement = yMaximum/10;
	NSInteger minorIncrement = majorIncrement/2;
    if (minorIncrement == 0) {
        minorIncrement = 1;
        majorIncrement = 2;
    }
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMaximum; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -y.majorTickLength - y.labelOffset;
			if (label) {
				[yLabels addObject:label];
			}
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
			[yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
}

- (void)configureLegend {
	// 1 - Get graph instance
	CPTGraph *graph = self.hostingView.hostedGraph;
	// 2 - Create legend
	CPTLegend *legend = [CPTLegend legendWithGraph:graph];
	// 3 - Configure legend
    NSInteger plotCount = [graph.allPlots count];
    NSInteger rowCount = (plotCount/4) + (plotCount % 4 == 0 ? 0:1);
    NSInteger colCount = 4;
	legend.numberOfRows = rowCount;
	legend.numberOfColumns = colCount;
	legend.fill = [CPTFill fillWithColor:[[CPTColor whiteColor] colorWithAlphaComponent:1.0]];
	legend.borderLineStyle = [CPTLineStyle lineStyle];
	legend.cornerRadius = 5.0;
	// 4 - Add legend to graph
	graph.legend = legend;
	graph.legendAnchor = CPTRectAnchorBottom;
	CGFloat legendPaddingWidth = -0.0f;
	CGFloat legendPaddingHeight = -2.0f;
	graph.legendDisplacement = CGPointMake(legendPaddingWidth, legendPaddingHeight);
}

- (void)initBradenPlot
{
    [self configureBradenHost];
    [self configureBradenGraph];
    [self configureBradenPlots];
    [self configureBradenAxes];
}

- (void)configureBradenHost
{
	self.hostingView.allowPinchScaling = NO;
}

- (void)configureBradenGraph
{
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
	self.hostingView.hostedGraph = graph;
	// 2 - Set graph title

	// 3 - Create and set text style

	// 4 - Set padding for plot area
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:16.0f];
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
}

- (void)configureBradenPlots
{
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostingView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	// 2 - Create a plot for each dataSource - keep each dataSource
    // update data for reference date @min.
    for (WoundStatusMeasurementRollup *woundStatusMeasurementRollup in self.woundStatusMeasurementRollups) {
        [woundStatusMeasurementRollup updateDataForReferenceDateDayNumber:self.minimumReferenceDayNumber];
    }
    NSMutableArray *dataSources = [[NSMutableArray alloc] initWithCapacity:[self.woundStatusMeasurementRollups count]];
    NSMutableArray *plots = [[NSMutableArray alloc] initWithCapacity:[self.woundStatusMeasurementRollups count]];
    for (WoundStatusMeasurementRollup *woundStatusMeasurementRollup in self.woundStatusMeasurementRollups) {
        // create a dataSource
        WoundStatusMeasurementPlotDataSource *dataSource = [[WoundStatusMeasurementPlotDataSource alloc] init];
        dataSource.woundStatusMeasurementRollup = woundStatusMeasurementRollup;
        [dataSources addObject:dataSource];
        // create plot
        CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
        plot.dataSource = dataSource;
        plot.delegate = self;
        plot.identifier = woundStatusMeasurementRollup.key;
        [graph addPlot:plot toPlotSpace:plotSpace];
        [plots addObject:plot];
    }
    self.plotDataSources = dataSources;
    // 3 - Set up plot space
	[plotSpace scaleToFitPlots:plots];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    xRange.location = CPTDecimalFromInteger(-kXPlotOffset);
    xRange.length = CPTDecimalAdd(CPTDecimalFromInteger(kXPlotOffset), CPTDecimalAdd(xRange.length, CPTDecimalFromFloat(0.25)));
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.05f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    yRange.length = CPTDecimalFromInteger(20);
    yRange.location = CPTDecimalFromInteger(0);
	plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    NSArray *colors = self.keyColors;
    NSArray *symbols = self.keySymbols;
    NSInteger index = 0;
    for (CPTScatterPlot *plot in plots) {
        CPTMutableLineStyle *lineStyle = [plot.dataLineStyle mutableCopy];
        lineStyle.lineWidth = 1.0;
        lineStyle.lineColor = [colors objectAtIndex:index];
        plot.dataLineStyle = lineStyle;
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [colors objectAtIndex:index];
        CPTPlotSymbol *symbol = [symbols objectAtIndex:index];
        symbol.fill = [CPTFill fillWithColor:[colors objectAtIndex:index]];
        symbol.lineStyle = symbolLineStyle;
        symbol.size = CGSizeMake(6.0f, 6.0f);
        plot.plotSymbol = symbol;
        ++index;
    }
}

- (void)configureBradenAxes
{
    // 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blackColor];
	axisTitleStyle.fontName = @"Helvetica";
	axisTitleStyle.fontSize = 7.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 1.0f;
	axisLineStyle.lineColor = [CPTColor grayColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor blackColor];
	axisTextStyle.fontName = @"Helvetica";
	axisTextStyle.fontSize = 7.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor grayColor];
	tickLineStyle.lineWidth = 1.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor lightGrayColor];
	tickLineStyle.lineWidth = 1.0f;
	CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor lightGrayColor];
	tickLineStyle.lineWidth = 1.0f;
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostedGraph.axisSet;
	// 3 - Configure x-axis
	CPTXYAxis *x = axisSet.xAxis;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 4.0f;
	x.minorTickLineStyle = axisLineStyle;
	x.minorTickLength = 2.0f;
	x.tickDirection = CPTSignNegative;
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    // build the labels and locations CPTAxis.-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber; maybe to determine which labels to skip
    CGFloat width = CGRectGetWidth(self.hostingView.bounds);
    CGFloat labelWidth = [@"00/00/00" sizeWithAttributes:self.tinyAttributes].width;
    NSInteger maximumLabelCount = width/labelWidth - 2;
    NSArray *dateStrings = self.dateStrings;
	CGFloat dateCount = [dateStrings count];
    NSInteger labelMod = dateCount/maximumLabelCount;
    if (labelMod == 0) {
        labelMod = 1;
    }
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xMinorLocations = [NSMutableSet setWithCapacity:dateCount];
	NSInteger location = 0;
    NSInteger index = 0;
	for (NSString *date in dateStrings) {
        if ((index % labelMod) > 0) {
			[xMinorLocations addObject:[NSNumber numberWithInteger:location]];
            ++location;
            ++index;
            continue;
        }
        // else
		CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date textStyle:x.labelTextStyle];
		label.tickLocation = CPTDecimalFromInteger(location);
		label.offset = x.majorTickLength;
		if (label) {
			[xLabels addObject:label];
			[xLocations addObject:[NSNumber numberWithInteger:location]];
		}
        ++location;
        ++index;
	}
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;
	x.minorTickLocations = xMinorLocations;
	// 4 - Configure y-axis
	CPTXYAxis *y = axisSet.yAxis;
    NSString *yUnits = kBradenScaleTitle;
	y.title = yUnits;
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -32.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 12.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLineStyle = axisLineStyle;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    CGFloat yMaximum = 16.0;
	NSInteger majorIncrement = 4;
	NSInteger minorIncrement = 2;
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMaximum; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -y.majorTickLength - y.labelOffset;
			if (label) {
				[yLabels addObject:label];
			}
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
			[yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
}

@end

@implementation PDFRenderer

@dynamic appDelegate, userDefaultsManager;
@synthesize defaultFontSize=_defaultFontSize;
@synthesize tinyFont=_tinyFont, smallFont=_smallFont, boldSmallFont=_boldSmallFont, normalFont=_normalFont;
@synthesize patient=_patient, wound=_wound, printConfiguration=_printConfiguration;
@synthesize pageRect=_pageRect, pageSize=_pageSize;
@dynamic pageInfoDictionary;
@dynamic templateNibNames, woundPhotosPerPage;
@synthesize templateNibObjects=_templateNibObjects;
@synthesize hostingView=_hostingView, rootView=_rootView, contentView=_contentView, pageHeaderView=_pageHeaderView, pageFooterView=_pageFooterView;
@synthesize graphableMeasurementTitles=_graphableMeasurementTitles;
@synthesize wountStatusMeasurementTitle2RollupByKeyMapMap=_wountStatusMeasurementTitle2RollupByKeyMapMap;
@synthesize woundStatusMeasurementTitle=_woundStatusMeasurementTitle, woundStatusMeasurementRollups=_woundStatusMeasurementRollups, key2RollupMap=_key2RollupMap, rollups=_rollups;
@dynamic hostedGraph, keyColors, keySymbols, isBradenScale;
@synthesize plotDataSources=_plotDataSources, dateStrings=_dateStrings, dateMinimum=_dateMinimum, dateMaximum=_dateMaximum;
@synthesize minimumReferenceDayNumber=_minimumReferenceDayNumber, maximumReferenceDayNumber=_maximumReferenceDayNumber;
@synthesize yMinimum=_yMinimum, yMaximum=_yMaximum, yMinimumValue=_yMinimumValue, yMaximumValue=_yMaximumValue, yUnits=_yUnits;
@synthesize patientDataSummaryView=_patientDataSummaryView, patientHeaderView=_patientHeaderView, bradenScaleGraphView=_bradenScaleGraphView;
@dynamic graphableMeasurementTitlesWithSufficientData;

- (id)init
{
    self = [super init];
    if (nil != self) {
        // handle document closing
        [[NSNotificationCenter defaultCenter] addObserverForName:kDocumentClosedNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [self handleDocumentClosed:[notification object]];
                                                      }];
    }
    return self;
}

- (NSMutableDictionary *)objectID2AttributedStringMap
{
    if (nil == _objectID2AttributedStringMap) {
        _objectID2AttributedStringMap = [[NSMutableDictionary alloc] init];
    }
    return _objectID2AttributedStringMap;
}

- (void)clearDataCache
{
    _objectID2AttributedStringMap = nil;
}

- (void)handleDocumentClosed:(NSString *)documentName
{
    [self clearDataCache];
}

- (CGFloat)defaultFontSize
{
    if (0.0 == _defaultFontSize) {
        _defaultFontSize = 12.0;
    }
    return _defaultFontSize;
}

- (UIFont *)tinyFont
{
    if (nil == _tinyFont) {
        _tinyFont = [UIFont systemFontOfSize:(self.defaultFontSize - 5.0)];
    }
    return _tinyFont;
}

- (UIFont *)smallFont
{
    if (nil == _smallFont) {
        _smallFont = [UIFont systemFontOfSize:(self.defaultFontSize - 3.0)];
    }
    return _smallFont;
}

- (UIFont *)boldSmallFont
{
    if (nil == _boldSmallFont) {
        _boldSmallFont = [UIFont boldSystemFontOfSize:(self.defaultFontSize - 3.0)];
    }
    return _boldSmallFont;
}

- (UIFont *)normalFont
{
    if (nil == _normalFont) {
        _normalFont = [UIFont systemFontOfSize:self.defaultFontSize];
    }
    return _normalFont;
}

- (NSDictionary *)tinyAttributes
{
    static NSDictionary *PDFTinyAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFTinyAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:(self.defaultFontSize - 5.0)], NSFontAttributeName,
                                   [UIColor blackColor], NSForegroundColorAttributeName,
                                   paragraphStyle, NSParagraphStyleAttributeName,
                                   nil];
    });
    return PDFTinyAttributes;
}

- (NSDictionary *)smallAttributes
{
    static NSDictionary *PDFSmallAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFSmallAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIFont systemFontOfSize:(self.defaultFontSize - 3.0)], NSFontAttributeName,
                              [UIColor blackColor], NSForegroundColorAttributeName,
                              paragraphStyle, NSParagraphStyleAttributeName,
                              nil];
    });
    return PDFSmallAttributes;
}

- (NSDictionary *)smallCenteredAttributes
{
    static NSDictionary *PDFSmallCenteredAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFSmallCenteredAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIFont systemFontOfSize:(self.defaultFontSize - 3.0)], NSFontAttributeName,
                              [UIColor blackColor], NSForegroundColorAttributeName,
                              paragraphStyle, NSParagraphStyleAttributeName,
                              nil];
    });
    return PDFSmallCenteredAttributes;
}

- (NSDictionary *)boldSmallAttributes
{
    static NSDictionary *PDFBoldSmallAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFBoldSmallAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIFont boldSystemFontOfSize:(self.defaultFontSize - 3.0)], NSFontAttributeName,
                              [UIColor blackColor], NSForegroundColorAttributeName,
                              paragraphStyle, NSParagraphStyleAttributeName,
                              nil];
    });
    return PDFBoldSmallAttributes;
}

- (NSDictionary *)boldSmallCenteredAttributes
{
    static NSDictionary *PDFBoldSmallCenteredAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFBoldSmallCenteredAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont boldSystemFontOfSize:(self.defaultFontSize - 3.0)], NSFontAttributeName,
                                  [UIColor blackColor], NSForegroundColorAttributeName,
                                  paragraphStyle, NSParagraphStyleAttributeName,
                                  nil];
    });
    return PDFBoldSmallCenteredAttributes;
}

- (NSDictionary *)normalAttributes
{
    static NSDictionary *PDFNormalAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFNormalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:self.defaultFontSize], NSFontAttributeName,
                               [UIColor blackColor], NSForegroundColorAttributeName,
                               paragraphStyle, NSParagraphStyleAttributeName,
                               nil];
    });
    return PDFNormalAttributes;
}

- (NSDictionary *)normalCenteredAttributes
{
    static NSDictionary *PDFNormalCenteredAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFNormalCenteredAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:self.defaultFontSize], NSFontAttributeName,
                               [UIColor blackColor], NSForegroundColorAttributeName,
                               paragraphStyle, NSParagraphStyleAttributeName,
                               nil];
    });
    return PDFNormalCenteredAttributes;
}

- (NSDictionary *)italicsAttributes
{
    static NSDictionary *PDFItalicsAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        PDFItalicsAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont italicSystemFontOfSize:self.defaultFontSize], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    });
    return PDFItalicsAttributes;
}

- (CPTGraphHostingView *)hostingView
{
    if (nil == _hostingView) {
        _hostingView = [[CPTGraphHostingView alloc] init];
        _hostingView.collapsesLayers = YES;
    }
    return _hostingView;
}

- (CPTXYGraph *)hostedGraph
{
    return (CPTXYGraph *)self.hostingView.hostedGraph;
}


- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UserDefaultsManager *)userDefaultsManager
{
    return self.appDelegate.userDefaultsManager;
}

#pragma mark - Data management

- (NSArray *)graphableMeasurementTitles
{
    if (nil == _graphableMeasurementTitles) {
        _graphableMeasurementTitles = [[[WCWoundMeasurement sortedRootGraphableWoundMeasurements:[self.wound managedObjectContext]] valueForKeyPath:@"title"] arrayByAddingObject:kBradenScaleTitle];
    }
    return _graphableMeasurementTitles;
}

- (NSArray *)graphableMeasurementTitlesWithSufficientData
{
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:16];
    for (NSString *woundMeasurementTitle in self.graphableMeasurementTitles) {
        NSDictionary *key2RollupMap = [self.wountStatusMeasurementTitle2RollupByKeyMapMap objectForKey:woundMeasurementTitle];
        for (NSString *key in key2RollupMap) {
            WoundStatusMeasurementRollup *rollup = [key2RollupMap objectForKey:key];
            if (rollup.valueCount >= 2) {
                [results addObject:woundMeasurementTitle];
                break;
            }
        }
    }
    return results;
}

- (NSMutableDictionary *)wountStatusMeasurementTitle2RollupByKeyMapMap
{
    if (nil == _wountStatusMeasurementTitle2RollupByKeyMapMap) {
        _wountStatusMeasurementTitle2RollupByKeyMapMap = [self.appDelegate.plotManager wountStatusMeasurementTitle2RollupByKeyMapMapForWound:self.wound
                                                                                                                  graphableMeasurementTitles:self.graphableMeasurementTitles];
    }
    return _wountStatusMeasurementTitle2RollupByKeyMapMap;
}

- (NSArray *)keyColors
{
    static NSArray *KeyColors = nil;
    if (nil == KeyColors) {
        KeyColors = [[NSArray alloc] initWithObjects:
                     [CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor],
                     [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor],
                     [CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor],
                     [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor],
                     [CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor],
                     [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor],
                     [CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor],
                     [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor],
                     nil];
    }
    return KeyColors;
}

- (NSArray *)keySymbols
{
    static NSArray *KeySymbols = nil;
    if (nil == KeySymbols) {
        KeySymbols = [NSArray arrayWithObjects:
                      [CPTPlotSymbol crossPlotSymbol], [CPTPlotSymbol ellipsePlotSymbol], [CPTPlotSymbol rectanglePlotSymbol], [CPTPlotSymbol plusPlotSymbol],
                      [CPTPlotSymbol starPlotSymbol], [CPTPlotSymbol diamondPlotSymbol], [CPTPlotSymbol trianglePlotSymbol], [CPTPlotSymbol trianglePlotSymbol],
                      [CPTPlotSymbol pentagonPlotSymbol], [CPTPlotSymbol hexagonPlotSymbol], [CPTPlotSymbol dashPlotSymbol], [CPTPlotSymbol snowPlotSymbol],
                      [CPTPlotSymbol crossPlotSymbol], [CPTPlotSymbol ellipsePlotSymbol], [CPTPlotSymbol rectanglePlotSymbol], [CPTPlotSymbol plusPlotSymbol],
                      [CPTPlotSymbol starPlotSymbol], [CPTPlotSymbol diamondPlotSymbol], [CPTPlotSymbol trianglePlotSymbol], [CPTPlotSymbol trianglePlotSymbol],
                      [CPTPlotSymbol pentagonPlotSymbol], [CPTPlotSymbol hexagonPlotSymbol], [CPTPlotSymbol dashPlotSymbol], [CPTPlotSymbol snowPlotSymbol],
                      nil];
    }
    return KeySymbols;
}

- (NSDate *)dateMinimum
{
    if (nil == _dateMinimum) {
        _dateMinimum = [self.woundStatusMeasurementRollups valueForKeyPath:@"@min.dateMinimum"];
    }
    return _dateMinimum;
}

- (NSDate *)dateMaximum
{
    if (nil == _dateMaximum) {
        _dateMaximum = [self.woundStatusMeasurementRollups valueForKeyPath:@"@max.dateMaximum"];
    }
    return _dateMaximum;
}

- (NSInteger)minimumReferenceDayNumber
{
    if (_minimumReferenceDayNumber == 0) {
        NSDate *dateMinimum = self.dateMinimum;
        _minimumReferenceDayNumber = [dateMinimum timeIntervalSinceReferenceDate]/kOneDayTimeInterval;
    }
    return _minimumReferenceDayNumber;
}

- (NSInteger)maximumReferenceDayNumber
{
    if (_maximumReferenceDayNumber == 0) {
        NSDate *dateMaximum = self.dateMaximum;
        _maximumReferenceDayNumber = [dateMaximum timeIntervalSinceReferenceDate]/kOneDayTimeInterval;
    }
    return _maximumReferenceDayNumber;
}

- (NSArray *)dateStrings
{
    if (nil == _dateStrings) {
        NSDate *dateMinimum = self.dateMinimum;
        NSDate *dateMaximum = self.dateMaximum;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:1];
        NSDate *date = dateMinimum;
        NSMutableArray *dateStrings = [[NSMutableArray alloc] initWithCapacity:128];
        while ([date compare:dateMaximum] != NSOrderedDescending) {
            [dateStrings addObject:[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
            date = [calendar dateByAddingComponents:components toDate:date options:0];
        }
        _dateStrings = dateStrings;
    }
    return _dateStrings;
}

- (CGFloat)yMinimum
{
    return [WCWoundMeasurement graphableRangeForMeasurementTitle:_woundStatusMeasurementTitle].location;
}

- (CGFloat)yMaximum
{
    if (0.0f == _yMaximum) {
        if (self.isBradenScale) {
            _yMaximum = 23.0;
        } else {
            _yMaximum = NSMaxRange([WCWoundMeasurement graphableRangeForMeasurementTitle:_woundStatusMeasurementTitle]);
        }
    }
    return _yMaximum;
}

- (CGFloat)yMinimumValue
{
    if (-1.0f == _yMinimumValue) {
        _yMinimumValue = [[self.woundStatusMeasurementRollups valueForKeyPath:@"@min.yMinimum"] floatValue];
    }
    return _yMinimumValue;
}

- (CGFloat)yMaximumValue
{
    if (-1.0f == _yMaximumValue) {
        _yMaximumValue = [[self.woundStatusMeasurementRollups valueForKeyPath:@"@max.yMaximum"] floatValue];
    }
    return _yMaximumValue;
}

- (NSString *)yUnits
{
    if (nil == _yUnits) {
        _yUnits = [[self.woundStatusMeasurementRollups lastObject] yUnit];
    }
    return _yUnits;
}

- (BOOL)isBradenScale
{
    return [kBradenScaleTitle isEqualToString:_woundStatusMeasurementTitle];
}

- (NSDictionary *)key2RollupMap
{
    if (nil == _key2RollupMap) {
        _key2RollupMap = [self.wountStatusMeasurementTitle2RollupByKeyMapMap objectForKey:self.woundStatusMeasurementTitle];
    }
    return _key2RollupMap;
}

- (NSArray *)woundStatusMeasurementRollups
{
    if (nil == _woundStatusMeasurementRollups) {
        NSDictionary *map = self.key2RollupMap;
        NSMutableArray *rollups = (NSMutableArray *)[map allValues];
        [rollups sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
        _woundStatusMeasurementRollups = rollups;
    }
    return _woundStatusMeasurementRollups;
}

#pragma mark - Drawing

// subclasses must override
- (void)drawToURL:(NSURL *)url
{
}

- (CGRect)pageRect
{
    if (CGRectIsEmpty(_pageRect)) {
        _pageRect = CGRectMake(0.0, 0.0, 612.0, 792.0);
    }
    return _pageRect;
}

- (CGSize)pageSize
{
    if (_pageSize.width == 0.0) {
        _pageSize = CGSizeMake(612, 792);
    }
    return _pageSize;
}

- (NSDictionary *)pageInfoDictionary
{
    if ([self.printConfiguration.password length] > 0) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                self.printConfiguration.password, kCGPDFContextUserPassword,
                self.printConfiguration.password, kCGPDFContextOwnerPassword, nil];

    }
    // else
    return nil;
}

// draws a border around the page with defined constants for insets
- (void)drawBorder
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor brownColor];
    CGRect rectFrame = CGRectInset(self.pageRect, kPDFBorderInset, kPDFBorderInset);
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, kPDFBorderWidth);
    CGContextStrokeRect(currentContext, rectFrame);
}

// draw a line yOffset from top of page using default x inset
- (void)drawLineAtYOffset:(CGFloat)yOffset color:(UIColor *)color
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, kPDFLineWidth);
    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    CGPoint startPoint = CGPointMake(kPDFMarginInset + kPDFBorderInset, yOffset);
    CGPoint endPoint = CGPointMake(self.pageSize.width - kPDFMarginInset - kPDFBorderInset, yOffset);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
}

// draw patient header, including Braden Scale graph using our placeholder views
- (CGFloat)drawPatientHeaderInRect:(CGRect)rect
{
    // size headings
    NSArray *headings = [NSArray arrayWithObjects:
                         @"Patient:",
                         @"DOB:",
                         @"Identifier:",
                         @"Initiated:",
                         @"Wounds/Photos:",
                         @"Braden Scale:", nil];
    WCBradenScale *bradenScale = [WCBradenScale latestBradenScale:self.patient.managedObjectContext create:NO];
    NSString *bradenScaleValue = @"Missing";
    if (nil != bradenScale) {
        bradenScaleValue = bradenScale.isScored ? [bradenScale.score stringValue]:@"Incomplete";
    }
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:8];
    [values addObject:self.patient.lastNameFirstNameOrAnonymous];
    [values addObject:(nil == self.patient.dateOfBirth ? [NSNull null]:[NSDateFormatter localizedStringFromDate:self.patient.dateOfBirth dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle])];
    [values addObject:(nil == self.patient.identifierEMR ? [NSNull null]:self.patient.identifierEMR)];
    [values addObject:(nil == self.patient.dateCreated ? [NSNull null]:[NSDateFormatter localizedStringFromDate:self.patient.dateCreated dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle])];
    [values addObject:[NSString stringWithFormat:@"%d/%d", self.patient.woundCount, self.patient.photosCount]];
    [values addObject:bradenScaleValue];
    UIView *placeholderView = self.patientDataSummaryView;
    CGRect aFrame = [self.rootView convertRect:placeholderView.frame fromView:placeholderView.superview];
    CGFloat x = CGRectGetMinX(aFrame);
    CGFloat y = CGRectGetMinY(aFrame);
    CGFloat valueX = 0.0;
    CGSize aSize = CGSizeZero;
    for (NSString *string in headings) {
        aSize = [string sizeWithAttributes:self.boldSmallAttributes];
        CGFloat xx = (x + aSize.width);
        if (xx > valueX) {
            valueX = xx;
        }
    }
    valueX += 8.0;
    valueX = ceilf(valueX);
    CGFloat valueWidth = CGRectGetMaxX(aFrame) - valueX;
    NSInteger index = 0;
    for (NSString *heading in headings) {
        aSize = [heading sizeWithAttributes:self.boldSmallAttributes];
        [heading drawAtPoint:CGPointMake(x, y) withAttributes:self.boldSmallAttributes];
        NSString *value = [values objectAtIndex:index++];
        if ([value isKindOfClass:[NSNull class]]) {
            y += aSize.height;
            continue;
        }
        // else
        aSize = CGSizeMake(valueWidth, CGFLOAT_MAX);
        CGRect boundingRect = [value boundingRectWithSize:aSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:self.smallAttributes
                                                  context:nil];
        boundingRect.origin.x = valueX;
        boundingRect.origin.y = y;
        [value drawInRect:boundingRect withAttributes:self.smallAttributes];
        y += boundingRect.size.height;
    }
    // draw Braden Scale graph
    NSArray *bradenScales = [WCBradenScale sortedScoredBradenScales:self.patient.managedObjectContext];
    aFrame = [self.rootView convertRect:self.bradenScaleGraphView.frame fromView:self.patientHeaderView];
    CGFloat width = CGRectGetWidth(aFrame);
    CGFloat height = CGRectGetHeight(aFrame);
    x = CGRectGetMinX(aFrame);
    y = CGRectGetMinY(aFrame);
    if ([bradenScales count] > 1) {
        // draw the graph
        [self drawBradenScalePlotForFrame:aFrame];
    } else {
        aFrame = CGRectInset(aFrame, 0.0, 24.0);
        [[UIColor darkGrayColor] set];
        UIRectFrame(aFrame);
        NSString *string = @"Insufficient Braden data";
        aSize = [string sizeWithAttributes:self.boldSmallCenteredAttributes];
        CGRect aRect = CGRectMake(x, roundf(y + (height - aSize.height)/2.0), width, aSize.height);
        [string drawInRect:aRect withAttributes:self.boldSmallCenteredAttributes];
    }
    // draw line
    CGFloat expectedMaxY = CGRectGetMaxY(rect);
    [self drawLineAtYOffset:expectedMaxY color:[UIColor blackColor]];
    // assume we don't extend below the expected y
    return y;
}

- (CGFloat)drawPatientWoundHeader:(WCWound *)wound inRect:(CGRect)aFrame draw:(BOOL)draw
{
    CGFloat x = CGRectGetMinX(aFrame);
    CGFloat y = CGRectGetMinY(aFrame);
    // size headings
    NSArray *headings = [NSArray arrayWithObjects:
                         @"Patient:",
                         @"Wound:",
                         @"Type:",
                         @"Location:", nil];
    NSArray *values = [NSArray arrayWithObjects:
                       [NSString stringWithFormat:@"%@, DOB: %@, ID: %@",
                        self.patient.lastNameFirstName,
                        nil == self.patient.dateOfBirth ? @" ":[NSDateFormatter localizedStringFromDate:self.patient.dateOfBirth dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle],
                        nil == self.patient.identifierEMR ? @" ":self.patient.identifierEMR],
                       wound.shortName,
                       (nil == wound.woundType ? @"Unspecified":[wound.woundTypeForDisplay componentsJoinedByString:@", "]),
                       (nil == wound.location ? @"Unspecified":wound.woundLocationAndPositionForDisplay),  nil];
    CGFloat valueX = 0.0;
    CGSize aSize= CGSizeZero;
    for (NSString *string in headings) {
        aSize = [string sizeWithAttributes:self.normalAttributes];
        CGFloat xx = (x + aSize.width);
        if (xx > valueX) {
            valueX = xx;
        }
    }
    valueX += 8.0;
    CGFloat valueWidth = CGRectGetMaxX(aFrame) - valueX - 4.0;
    NSInteger i = 0;
    for (NSString *heading in headings) {
        if (draw) {
            [heading drawAtPoint:CGPointMake(x, y) withAttributes:self.normalAttributes];
        }
        NSString *value = [values objectAtIndex:i++];
        aSize = CGSizeMake(valueWidth, CGFLOAT_MAX);
        CGRect boundingRect = [value boundingRectWithSize:aSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:self.normalAttributes
                                                  context:nil];
        boundingRect.origin.x = valueX;
        boundingRect.origin.y = y;
        aSize = boundingRect.size;
        if (draw) {
            [value drawInRect:boundingRect withAttributes:self.normalAttributes];
        }
        y += aSize.height;
    }
    return y;
}

- (CGFloat)drawWoundSummaryForWound:(WCWound *)wound inRect:(CGRect)aFrame draw:(BOOL)draw
{
    CGFloat minX = CGRectGetMinX(aFrame);
    CGFloat maxX = CGRectGetMaxX(aFrame);
    CGFloat minY = CGRectGetMinY(aFrame);
    CGFloat maxY = CGRectGetMaxY(aFrame);
    CGFloat actualY = minY;
    CGFloat height = CGRectGetHeight(aFrame);
    // size headings
    NSArray *headings = [NSArray arrayWithObjects:
                         @"Wound:",
                         @"Type:",
                         @"Location:", nil];
    NSArray *values = [NSArray arrayWithObjects:
                       wound.shortName,
                       (nil == wound.woundType ? @"Unspecified":[wound.woundTypeForDisplay componentsJoinedByString:@", "]),
                       (nil == wound.location ? @"Unspecified":wound.woundLocationAndPositionForDisplay),  nil];
    CGFloat valueX = 0.0;
    for (NSString *string in headings) {
        CGSize aSize = [string sizeWithAttributes:self.boldSmallAttributes];
        valueX = MAX(valueX, minX + aSize.width);
    }
    valueX += 8.0;
    CGFloat valueWidth = maxX - valueX - 4.0;
    CGRect valueRect = CGRectMake(valueX, minY, valueWidth, height);
    NSInteger i = 0;
    for (NSString *heading in headings) {
        if (draw) {
            [heading drawAtPoint:CGPointMake(minX, minY) withAttributes:self.boldSmallAttributes];
        }
        NSString *value = [values objectAtIndex:i++];
        CGRect boundingRect = [value boundingRectWithSize:aFrame.size
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:self.smallAttributes
                                                  context:nil];
        CGFloat boundingRectHeight = CGRectGetHeight(boundingRect);
        actualY += boundingRectHeight;
        if (draw) {
            [value drawInRect:valueRect withAttributes:self.smallAttributes];
        }
        valueRect = CGRectOffset(valueRect, 0.0, boundingRectHeight);
        minY += boundingRectHeight;
    }
    return (maxY - actualY);
}

- (CGFloat)drawWoundPhoto:(WCWoundPhoto *)woundPhoto inRect:(CGRect)aFrame
{
    NSManagedObjectID *objectID = [woundPhoto objectID];
    NSArray *sortedWoundPhotoIDs = woundPhoto.wound.sortedWoundPhotoIDs;
    NSString *string = [NSString stringWithFormat:@"Photo %d/%d taken %@",
                        [sortedWoundPhotoIDs indexOfObject:objectID] + 1,
                        [sortedWoundPhotoIDs count],
                        [NSDateFormatter localizedStringFromDate:woundPhoto.dateCreated dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
    // draw woundPhoto first
    UIImage *image = woundPhoto.thumbnailLarge;
    CGRect photoFrame = [PDFRenderer aspectFittedRect:CGRectMake(0.0, 0.0, image.size.width, image.size.height) max:aFrame];
    [image drawInRect:photoFrame];
    // now the text
    CGRect boundingRect = [string boundingRectWithSize:aFrame.size
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:self.smallCenteredAttributes
                                               context:nil];
    [string drawInRect:CGRectOffset(aFrame, 0.0, -CGRectGetHeight(boundingRect)) withAttributes:self.smallCenteredAttributes];
    return CGRectGetMaxY(aFrame);
}

- (NSMutableAttributedString *)attributedStringForCoreTextDataSource:(id<WCCoreTextDataSource>)coreTextDataSource
                                                            rectLeft:(CGRect)frameLeft
                                                          rectMiddle:(CGRect)frameMiddle
                                                           rectRight:(CGRect)frameRight
{
    NSMutableAttributedString *mutableAttributedString = [self.objectID2AttributedStringMap objectForKey:[coreTextDataSource objectID]];
    if (nil == mutableAttributedString) {
        mutableAttributedString = [coreTextDataSource descriptionAsMutableAttributedStringWithBaseFontSize:12.0];
        [self.objectID2AttributedStringMap setObject:mutableAttributedString forKey:[coreTextDataSource objectID]];
    }
    // check if there is enough room at current font size
    CGFloat width = CGRectGetWidth(frameLeft);
    CGFloat height = CGRectGetHeight(frameLeft);
    NSStringDrawingContext *stringDrawingContext = [[NSStringDrawingContext alloc] init];
    stringDrawingContext.minimumScaleFactor = 0.5;
    NSInteger validFrameCount = 0;
    if (!CGRectIsEmpty(frameLeft)) {
        ++validFrameCount;
    }
    if (!CGRectIsEmpty(frameMiddle)) {
        ++validFrameCount;
    }
    if (!CGRectIsEmpty(frameRight)) {
        ++validFrameCount;
    }
    CGFloat targetHeight = validFrameCount * height;
    CGRect boundingRect = [mutableAttributedString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                context:stringDrawingContext];
    if (CGRectGetHeight(boundingRect) > targetHeight) {
        // no enough room - scale the font
        CGFloat fontSize = floorf(targetHeight/CGRectGetHeight(boundingRect) * 12.0);
        if (fontSize < 9.0) {
            return nil;
        }
        // else accept
        mutableAttributedString = [coreTextDataSource descriptionAsMutableAttributedStringWithBaseFontSize:fontSize];
        [self.objectID2AttributedStringMap setObject:mutableAttributedString forKey:[coreTextDataSource objectID]];
    }
    return mutableAttributedString;
}

// draw attributed string flowing into possible 3 frames
// return additional height needed
- (CGFloat)drawAttributedStringForDataSource:(id<WCCoreTextDataSource>)coreTextDataSource
                                    rectLeft:(CGRect)frameLeft
                                  rectMiddle:(CGRect)frameMiddle
                                   rectRight:(CGRect)frameRight
{
    // get the data
    NSMutableAttributedString *mutableAttributedString = [self attributedStringForCoreTextDataSource:coreTextDataSource
                                                                                            rectLeft:frameLeft
                                                                                          rectMiddle:frameMiddle
                                                                                           rectRight:frameRight];
    return [self drawAttributedString:mutableAttributedString
                             rectLeft:frameLeft
                           rectMiddle:frameMiddle
                            rectRight:frameRight];
}

- (CGFloat)drawAttributedString:(NSMutableAttributedString *)attributedString
                       rectLeft:(CGRect)frameLeft
                     rectMiddle:(CGRect)frameMiddle
                      rectRight:(CGRect)frameRight
{
    // build Core Text stack
    NSUInteger nextContainerIndex = 1;
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *tc1 = [[NSTextContainer alloc] initWithSize:frameLeft.size];
    [layoutManager addTextContainer:tc1];
    NSTextContainer *tc2 = nil;
    if (!CGRectIsEmpty(frameMiddle)) {
        tc2 = [[NSTextContainer alloc] initWithSize:frameMiddle.size];
        [layoutManager addTextContainer:tc2];
        ++nextContainerIndex;
    }
    NSTextContainer *tc3 = nil;
    if (!CGRectIsEmpty(frameRight)) {
        tc3 = [[NSTextContainer alloc] initWithSize:frameRight.size];
        [layoutManager addTextContainer:tc3];
        ++nextContainerIndex;
    }
    // fill each rect
    CGFloat deltaY = 0.0;
    NSRange aRange1 = [layoutManager glyphRangeForTextContainer:tc1];
    [layoutManager drawBackgroundForGlyphRange:aRange1 atPoint:frameLeft.origin];
    [layoutManager drawGlyphsForGlyphRange:aRange1 atPoint:frameLeft.origin];
    if (nil != tc2) {
        NSRange aRange2 = [layoutManager glyphRangeForTextContainer:tc2];
        if (aRange2.length > 0) {
            [layoutManager drawBackgroundForGlyphRange:aRange2 atPoint:frameMiddle.origin];
            [layoutManager drawGlyphsForGlyphRange:aRange2 atPoint:frameMiddle.origin];
        }
    }
    if (nil != tc3) {
        NSRange aRange3 = [layoutManager glyphRangeForTextContainer:tc3];
        if (aRange3.length > 0) {
            [layoutManager drawBackgroundForGlyphRange:aRange3 atPoint:frameRight.origin];
            [layoutManager drawGlyphsForGlyphRange:aRange3 atPoint:frameRight.origin];
        }
    }
    NSUInteger firstUnlaidCharacterIndex = [layoutManager firstUnlaidCharacterIndex];
    if (firstUnlaidCharacterIndex < [attributedString length]) {
        // figure out how much more is needed
        CGRect aFrame = frameLeft;
        aFrame.size.height = CGFLOAT_MAX;
        NSTextContainer *tc4 = [[NSTextContainer alloc] initWithSize:aFrame.size];
        [layoutManager insertTextContainer:tc4 atIndex:nextContainerIndex];
        NSRange aRange4 = [layoutManager glyphRangeForTextContainer:tc4];
        if (aRange4.length > 0) {
            CGRect usedRect = [layoutManager usedRectForTextContainer:tc4];
            deltaY = CGRectGetHeight(usedRect);
        }
    }
    return deltaY;
}

- (CGFloat)drawWoundTreatmentForWound:(WCWound *)wound inRect:(CGRect)aFrame draw:(BOOL)draw
{
    [self drawAttributedStringForDataSource:wound.lastWoundTreatmentGroup
                                   rectLeft:aFrame
                                 rectMiddle:CGRectZero
                                  rectRight:CGRectZero];
    return 0.0;
}

- (CGFloat)drawWoundTreatment:(WCWoundTreatmentGroup *)woundTreatmentGroup inRect:(CGRect)aFrame draw:(BOOL)draw
{
    return 0.0;
}

- (void)drawPageHeader:(NSInteger)pageNumber
{
    NSString *pdfHeaderPrefix = @"WoundMap Report";
    if ([self.userDefaultsManager.pdfHeaderPrefix length] > 0) {
        pdfHeaderPrefix = self.userDefaultsManager.pdfHeaderPrefix;
    }
    NSString *headerString = [NSString stringWithFormat:@"%@ - %@", pdfHeaderPrefix, self.patient.lastNameFirstNameOrAnonymous];
    CGSize aSize = [headerString sizeWithAttributes:self.normalAttributes];
    CGRect aRect = CGRectInset(self.pageHeaderView.frame, 0.0, roundf((CGRectGetHeight(self.pageHeaderView.frame) - aSize.height)/2.0));
    [headerString drawInRect:aRect withAttributes:self.normalCenteredAttributes];
}

- (void)drawPageFooter:(NSInteger)pageNumber
{
    NSString *footerString = [NSString stringWithFormat:@"Page %d (printed by WoundMap\u24C7 %@)", pageNumber, [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle]];
    CGSize aSize = [footerString sizeWithAttributes:self.smallCenteredAttributes];
    CGRect aRect = CGRectInset(self.pageFooterView.frame, 0.0, roundf((CGRectGetHeight(self.pageFooterView.frame) - aSize.height)/2.0));
    [footerString drawInRect:aRect withAttributes:self.smallCenteredAttributes];
}

- (void)drawLineString:(NSString *)string inFrame:(CGRect)rect fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
    // get the context
	CGContextRef context = UIGraphicsGetCurrentContext();
    // create a font
	CTFontRef font = CTFontCreateUIFontForLanguage(bold ? kCTFontUIFontEmphasizedSystem:kCTFontSystemFontType, fontSize, NULL);
    // Initialize string, font, and context
    CFStringRef keys[] = { kCTFontAttributeName };
    CFTypeRef values[] = { font };
    CFDictionaryRef attributes =
    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                       (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                       &kCFTypeDictionaryKeyCallBacks,
                       &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, (__bridge CFStringRef)(string), attributes);
    CFRelease(attributes);
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    // Set text position and draw the line into the graphics context
    CGContextSetTextPosition(context, 10.0, 10.0);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(context, 0, rect.origin.y*2);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTLineDraw(line, context);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, (-1)*rect.origin.y*2);
    
    CFRelease(line);
}

- (void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect fontSize:(CGFloat)fontSize bold:(BOOL)bold centered:(BOOL)centered
{
    // create a font
	CTFontRef font = CTFontCreateUIFontForLanguage(bold ? kCTFontUIFontEmphasizedSystem:kCTFontSystemFontType, fontSize, NULL);
    // Initialize string, font, and context
    CFDictionaryRef attributes;
    CFAttributedStringRef attrString;
    if (centered) {
        CTTextAlignment centerValue = kCTCenterTextAlignment;
        CTParagraphStyleSetting center = {kCTParagraphStyleSpecifierAlignment, sizeof(centerValue), &centerValue};
        CTParagraphStyleSetting pss[1] = {center};
        CTParagraphStyleRef ps = CTParagraphStyleCreate(pss, 1);
        CFStringRef keys[] = { kCTFontAttributeName, kCTParagraphStyleAttributeName };
        CFTypeRef values[] = { font, ps };
        attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                                        (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                                        &kCFTypeDictionaryKeyCallBacks,
                                        &kCFTypeDictionaryValueCallBacks);
        attrString = CFAttributedStringCreate(kCFAllocatorDefault, (__bridge CFStringRef)(textToDraw), attributes);
        CFRelease(ps);
    } else {
        CFStringRef keys[] = { kCTFontAttributeName };
        CFTypeRef values[] = { font };
        attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                                        (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                                        &kCFTypeDictionaryKeyCallBacks,
                                        &kCFTypeDictionaryValueCallBacks);
        attrString = CFAttributedStringCreate(kCFAllocatorDefault, (__bridge CFStringRef)(textToDraw), attributes);
    }
    
    CFRelease(attributes);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, frameRect.origin.y*2);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, (-1)*frameRect.origin.y*2);
    
    
    CFRelease(frameRef);
    CFRelease(attrString);
    CFRelease(framesetter);
}

#pragma mark - Plot

- (void)drawBradenScalePlotForFrame:(CGRect)frame
{
    // clear cache
    [self prepareForPlot];
    // update hostingView
    self.hostingView.frame = frame;
    // set woundStatusMeasurementTitle, which will determine the data to plot
    self.woundStatusMeasurementTitle = kBradenScaleTitle;
    // configure plot
    [self initBradenPlot];
    // get image
    [[self.hostingView.hostedGraph imageOfLayer] drawInRect:frame];
}

- (void)drawPlotForMeasurementTitle:(NSString *)woundStatusMeasurementTitle frame:(CGRect)frame
{
    // clear cache
    [self prepareForPlot];
    // update hostingView
    self.hostingView.frame = frame;
    // set woundStatusMeasurementTitle, which will determine the data to plot
    self.woundStatusMeasurementTitle = woundStatusMeasurementTitle;
    // configure plot
    [self initPlot];
    // convert - get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    // translate
    CGContextTranslateCTM(currentContext, CGRectGetMinX(frame), CGRectGetMinY(frame));
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    // render into context
    [self.hostingView.hostedGraph layoutAndRenderInContext:currentContext];
    // translate
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, (-1)*CGRectGetMinX(frame), (-1)*CGRectGetMinY(frame));
}

// call before new plot
- (void)prepareForPlot
{
    _hostingView = nil;
    _woundStatusMeasurementTitle = nil;
    _woundStatusMeasurementRollups = nil;
    _key2RollupMap = nil;
    _rollups = nil;
    _dateStrings = nil;
    _dateMinimum = nil;
    _dateMaximum = nil;
    _minimumReferenceDayNumber = 0;
    _minimumReferenceDayNumber = 0;
    _yMaximum = 0;
    _yMinimumValue = -1.0f;
    _yMaximumValue = -1.0f;
    _yUnits = nil;
}

#pragma mark - Utilities

- (void)adjustPlaceholdersBelow:(CGFloat)y byAmount:(CGFloat)deltaY
{
    NSArray *subviews = self.contentView.subviews;
    for (UIView *aView in subviews) {
        CGRect aFrame = aView.frame;
        if (CGRectGetMinY(aFrame) > y) {
            aFrame.origin.y += deltaY;
            aView.frame = aFrame;
        }
    }
}

+ (CGRect)aspectFittedRect:(CGRect)inRect max:(CGRect)maxRect
{
	CGFloat originalAspectRatio = inRect.size.width / inRect.size.height;
	CGFloat maxAspectRatio = maxRect.size.width / maxRect.size.height;
	CGRect newRect = maxRect;
	if (originalAspectRatio > maxAspectRatio) { // scale by width
		newRect.size.height = maxRect.size.height * inRect.size.height / inRect.size.width;
		newRect.origin.y += (maxRect.size.height - newRect.size.height)/2.0;
	} else {
		newRect.size.width = maxRect.size.height  * inRect.size.width / inRect.size.height;
		newRect.origin.x += (maxRect.size.width - newRect.size.width)/2.0;
	}
	return CGRectIntegral(newRect);
}


@end

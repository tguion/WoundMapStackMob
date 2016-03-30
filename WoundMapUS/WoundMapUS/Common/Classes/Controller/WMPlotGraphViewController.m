//
//  WMPlotGraphViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMPlotGraphViewController.h"
#import "WMWound.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurement.h"
#import "WMWoundMeasurementValue.h"
#import "WMBradenScale.h"
#import "WMWoundPhoto.h"
#import "WoundStatusMeasurementRollup.h"
#import "WoundAreaPlotDataSource.h"
#import "WMCorePlotManager.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@interface WMPlotGraphViewController ()

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostingView;  // view hosting the graph
@property (weak, nonatomic) IBOutlet UIImageView *imageView;            // imageView to show woundPhoto
@property (readonly, nonatomic) CPTXYGraph *hostedGraph;                // hosted graph in hostingView
@property (strong, nonatomic) NSArray *plotDataSources;                 // one for each key of WMWoundMeasurement
@property (readonly, nonatomic) NSArray *keyColors;                     // colors for each key
@property (readonly, nonatomic) NSArray *keySymbols;                    // symbols for each key
@property (strong, nonatomic) NSArray *dateStrings;                     // possible x-axis labels
@property (strong, nonatomic) NSDate *dateMinimum;                      // min date for all keys in plotDataSources
@property (strong, nonatomic) NSDate *dateMaximum;                      // max date for all keys in plotDataSources
@property (nonatomic) NSInteger minimumReferenceDayNumber;              // minimum day number since reference date to adjust x-values of data
@property (nonatomic) NSInteger maximumReferenceDayNumber;              // maximum day number since reference date
@property (nonatomic) CGFloat yMinimum;                                 // minimum possible value for data types
@property (nonatomic) CGFloat yMaximum;                                 // maximum possible value for data types
@property (nonatomic) CGFloat yMinimumValue;                            // minimum value of selected data
@property (nonatomic) CGFloat yMaximumValue;                            // maximum value of selected data
@property (readonly, nonatomic) BOOL isBradenScale;
@property (strong, nonatomic) NSString *yUnits;                         // units of y-axis
@property (strong, nonatomic) CPTLegend *legend;                        // graph legend
@property (nonatomic) CGPoint pointDragBegan;                           // y value of drag begin
@property (strong, nonatomic) WMWoundPhoto *woundPhoto;                 // woundPhoto for current touch event

@end

@interface WMPlotGraphViewController (PrivateMethods)
- (void)initPlot;
- (void)configureHost;
- (void)configureGraph;
- (void)configurePlots;
- (void)configureAxes;
- (void)configureLegend;
- (WMWoundPhoto *)woundPhotoForIndex:(NSInteger)index;
- (void)updateWoundPhotoImageViewForPlotSpace:(CPTPlotSpace *)space dragAtPoint:(CGPoint)point event:(CPTNativeEvent *)event;
- (void)updateWoundPhotoForPlotSpace:(CPTPlotSpace *)space point:(CGPoint)point event:(CPTNativeEvent *)event;
@end

@implementation WMPlotGraphViewController (PrivateMethods)

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
	[graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
	self.hostingView.hostedGraph = graph;
	// 2 - Set graph title
	NSString *title = self.woundStatusMeasurementTitle;
	graph.title = title;
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
	// 4 - Set padding for plot area
	graph.paddingLeft = 0.0f;
	graph.paddingTop = 20.0f;
	graph.paddingRight = 0.0f;
	graph.paddingBottom = 0.0f;
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:30.0f];
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;
}

- (void)configurePlots
{
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostingView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.delegate = self;
	// 2 - Create a plot for each dataSource - keep each dataSource
    // update data for reference date @min.
    for (WoundStatusMeasurementRollup *woundStatusMeasurementRollup in self.woundStatusMeasurementRollups) {
        //DLog(@"%@.%@ BEFORE update: %@", woundStatusMeasurementRollup.title, woundStatusMeasurementRollup.key, [woundStatusMeasurementRollup description]);
        [woundStatusMeasurementRollup updateDataForReferenceDateDayNumber:self.minimumReferenceDayNumber];
        //DLog(@"%@.%@ AFTER update: %@", woundStatusMeasurementRollup.title, woundStatusMeasurementRollup.key, [woundStatusMeasurementRollup description]);
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
    xRange.location = CPTDecimalFromInteger(-kXOffset);
    xRange.length = CPTDecimalAdd(CPTDecimalFromInteger(kXOffset), xRange.length);
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
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
	axisTitleStyle.color = [CPTColor whiteColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [CPTColor whiteColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor whiteColor];
	axisTextStyle.fontName = @"Helvetica-Bold";
	axisTextStyle.fontSize = 11.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor whiteColor];
	tickLineStyle.lineWidth = 2.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 1.0f;
	CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor grayColor];
	tickLineStyle.lineWidth = 1.0f;
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostedGraph.axisSet;
	// 3 - Configure x-axis
	CPTXYAxis *x = axisSet.xAxis;
	x.title = @"Date";
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 20.0f;
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
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat labelWidth = [@"00/00/00" sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11.0]}].width;
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
    NSString *yUnits = self.yUnits;
	y.title = @"Assessments";
    if ([yUnits length] > 0) {
        y.title = [NSString stringWithFormat:@"Assessments (%@)", yUnits];
    }
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
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
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
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
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
	CGFloat legendPaddingHeight = +2.0f;
	graph.legendDisplacement = CGPointMake(legendPaddingWidth, legendPaddingHeight);
}

- (WMWoundPhoto *)woundPhotoForIndex:(NSInteger)index
{
    WoundStatusMeasurementRollup *rollup = [self.woundStatusMeasurementRollups lastObject];
    WMWoundMeasurementGroup *woundMeasurementGroup = (WMWoundMeasurementGroup *)[self.managedObjectContext objectWithID:[rollup.woundMeasurementGroupObjectIDs objectAtIndex:index]];
    return woundMeasurementGroup.woundPhoto;
}

- (void)updateWoundPhotoImageViewForPlotSpace:(CPTPlotSpace *)space dragAtPoint:(CGPoint)point event:(CPTNativeEvent *)event
{
    CGFloat swipeHeight = CGRectGetHeight(self.view.bounds)/2.0;
    //    CGFloat xDelta = fabsf(self.pointDragBegan.x - point.x);
    CGFloat yDelta = fabsf(self.pointDragBegan.y - point.y)/swipeHeight;
    if (yDelta > 0.1) {
        [self updateWoundPhotoForPlotSpace:space point:point event:event];
        self.imageView.hidden = NO;
        self.imageView.alpha = (yDelta > 1.0 ? 1.0:yDelta);
        //        DLog(@"drag: x:%f y:%f", xDelta, yDelta);
    }
}

- (void)updateWoundPhotoForPlotSpace:(CPTPlotSpace *)space point:(CGPoint)point event:(CPTNativeEvent *)event
{
    double plotPoint[] = {0.0, 0.0};
    [space doublePrecisionPlotPoint:plotPoint numberOfCoordinates:space.numberOfCoordinates forPlotAreaViewPoint:point];
    plotPoint[0] -= kXOffset; // emperical
    plotPoint[1] -= 1.7; // emperical
    //DLog(@"point (%f,%f) -> (%lf,%lf)", point.x, point.y, plotPoint[0], plotPoint[1]);
    NSInteger xDataPoint = plotPoint[0];
    if (xDataPoint < 0) {
        xDataPoint = 0;
    }
    NSDate *woundPhotoDate = nil;
    WMWoundMeasurementGroup *woundMeasurementGroup = nil;
    for (WoundStatusMeasurementRollup *rollup in self.woundStatusMeasurementRollups) {
        if (0 == [rollup.woundMeasurementGroupObjectIDs count]) {
            continue;
        }
        // else
        woundPhotoDate = [rollup dateForDayNumber:xDataPoint];
        if (nil != woundPhotoDate) {
            // found one
            NSManagedObjectID *objectID = [rollup.woundMeasurementGroupObjectIDs objectAtIndex:[rollup.dates indexOfObject:woundPhotoDate]];
            woundMeasurementGroup = (WMWoundMeasurementGroup *)[self.managedObjectContext objectWithID:objectID];
            break;
        }
    }
    if (nil != woundMeasurementGroup) {
        // date is for a WMWoundStatus
        self.woundPhoto = woundMeasurementGroup.woundPhoto;
        //DLog(@"Found woundPhoto %@ for date %@", self.woundPhoto, woundPhotoDate);
    }
}

@end

@implementation WMPlotGraphViewController

@synthesize woundPhoto=_woundPhoto;

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = _woundStatusMeasurementTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedAction:)];
    _yMinimumValue = -1.0f;
    _yMaximumValue = -1.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // setup graph
    [self initPlot];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // clear our cache here
    [self clearDataCache];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _dateStrings = nil;
    _dateMinimum = nil;
    _dateMaximum = nil;
    _yUnits = nil;
}

// save data in any view before view goes away
- (void)preserveDataInViews
{
}

- (void)clearDataCache
{
    _woundStatusMeasurementRollups = nil;
    _woundPhoto = nil;
    _dateStart = nil;
    _dateEnd = nil;
    _dateMinimum = nil;
    _dateMaximum = nil;
    _legend = nil;
    _plotDataSources = nil;
    _dateStrings = nil;
    _dateMinimum = nil;
    _dateMaximum = nil;
}

#pragma mark - Accessors

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        // now landscape
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.legend.hidden = YES;
    } else if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        // now portrait
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.legend.hidden = NO;
    }
}

#pragma mark - Core

- (CPTXYGraph *)hostedGraph
{
    return (CPTXYGraph *)self.hostingView.hostedGraph;
}

// begin move to refactor

- (NSArray *)keyColors
{
    static NSArray *KeyColors = nil;
    if (nil == KeyColors) {
        KeyColors = [[NSArray alloc] initWithObjects:[CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor], [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor],
                     [CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor], [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor],
                     [CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor], [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor],
                     [CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor], [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor brownColor], nil];
    }
    return KeyColors;
}

- (NSArray *)keySymbols
{
    static NSArray *KeySymbols = nil;
    if (nil == KeySymbols) {
        KeySymbols = [NSArray arrayWithObjects:[CPTPlotSymbol crossPlotSymbol], [CPTPlotSymbol ellipsePlotSymbol], [CPTPlotSymbol rectanglePlotSymbol], [CPTPlotSymbol plusPlotSymbol],
                      [CPTPlotSymbol starPlotSymbol], [CPTPlotSymbol diamondPlotSymbol], [CPTPlotSymbol trianglePlotSymbol], [CPTPlotSymbol trianglePlotSymbol],
                      [CPTPlotSymbol pentagonPlotSymbol], [CPTPlotSymbol hexagonPlotSymbol], [CPTPlotSymbol dashPlotSymbol], [CPTPlotSymbol snowPlotSymbol],
                      [CPTPlotSymbol crossPlotSymbol], [CPTPlotSymbol ellipsePlotSymbol], [CPTPlotSymbol rectanglePlotSymbol], [CPTPlotSymbol plusPlotSymbol],
                      [CPTPlotSymbol starPlotSymbol], [CPTPlotSymbol diamondPlotSymbol], [CPTPlotSymbol trianglePlotSymbol], [CPTPlotSymbol trianglePlotSymbol],
                      [CPTPlotSymbol pentagonPlotSymbol], [CPTPlotSymbol hexagonPlotSymbol], [CPTPlotSymbol dashPlotSymbol], [CPTPlotSymbol snowPlotSymbol],
                      [CPTPlotSymbol crossPlotSymbol], [CPTPlotSymbol ellipsePlotSymbol], [CPTPlotSymbol rectanglePlotSymbol], [CPTPlotSymbol plusPlotSymbol],
                      [CPTPlotSymbol starPlotSymbol], [CPTPlotSymbol diamondPlotSymbol], [CPTPlotSymbol trianglePlotSymbol], [CPTPlotSymbol trianglePlotSymbol],
                      [CPTPlotSymbol pentagonPlotSymbol], [CPTPlotSymbol hexagonPlotSymbol], [CPTPlotSymbol dashPlotSymbol], [CPTPlotSymbol snowPlotSymbol], nil];
    }
    return KeySymbols;
}

- (NSDate *)dateMinimum
{
    if (nil == _dateMinimum) {
        _dateMinimum = self.dateStart;
    }
    return _dateMinimum;
}

- (NSDate *)dateMaximum
{
    if (nil == _dateMaximum) {
        _dateMaximum = self.dateEnd;
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
    return [WMWoundMeasurement graphableRangeForMeasurementTitle:_woundStatusMeasurementTitle].location;
}

- (CGFloat)yMaximum
{
    if (0.0f == _yMaximum) {
        if (self.isBradenScale) {
            _yMaximum = 24.0;
        } else {
            _yMaximum = NSMaxRange([WMWoundMeasurement graphableRangeForMeasurementTitle:_woundStatusMeasurementTitle]);
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

// end move to refactor

- (void)setWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    if (_woundPhoto == woundPhoto) {
        return;
    }
    // else
    [self willChangeValueForKey:@"woundPhoto"];
    _woundPhoto = woundPhoto;
    [self didChangeValueForKey:@"woundPhoto"];
    // update from back end
    if (woundPhoto && nil == woundPhoto.thumbnail) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [ff loadBlobsForObj:woundPhoto onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            id data = woundPhoto.thumbnail;
            if ([data isKindOfClass:[NSData class]]) {
                woundPhoto.thumbnail = [UIImage imageWithData:data];
            }
            data = woundPhoto.thumbnailLarge;
            if ([data isKindOfClass:[NSData class]]) {
                woundPhoto.thumbnailLarge = [UIImage imageWithData:data];
            }
            data = woundPhoto.thumbnailMini;
            if ([data isKindOfClass:[NSData class]]) {
                woundPhoto.thumbnailMini = [UIImage imageWithData:data];
            }
            [[woundPhoto managedObjectContext] MR_saveToPersistentStoreAndWait];
            _imageView.image = woundPhoto.thumbnail;
        }];
    } else {
        _imageView.image = woundPhoto.thumbnail;
    }
}

#pragma mark - Actions

- (IBAction)hideShowLegend:(id)sender
{
    if (nil != self.hostedGraph.legend) {
        // showing, so hide
        self.hostedGraph.legend = nil;
        self.navigationItem.rightBarButtonItem.title = @"Show Legend";
    } else {
        self.hostedGraph.legend = self.legend;
        self.navigationItem.rightBarButtonItem.title = @"Hide Legend";
    }
}

- (IBAction)finishedAction:(id)sender
{
    [self.delegate plotViewControllerDidFinish:self];
}

#pragma mark - CPTPlotSpaceDelegate

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    if (self.isBradenScale) {
        return YES;
    }
    // else save the y value to determine how to bleed in woundPhoto.thumbnail
    self.pointDragBegan = point;
    [self updateWoundPhotoForPlotSpace:space point:point event:event];
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    [self updateWoundPhotoImageViewForPlotSpace:space dragAtPoint:point event:event];
    return NO;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    self.pointDragBegan = CGPointZero;
    self.imageView.hidden = YES;
    self.imageView.alpha = 0.0;
    return YES;
}

#pragma mark - CPTScatterPlotDelegate <CPTPlotDelegate>

/** @brief @optional Informs the delegate that a data point was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx
{
    if (self.isBradenScale) {
        return;
    }
    // else
    //DLog(@"Plot %@ selected at index %d", plot.identifier, idx);
    self.imageView.image = [self woundPhotoForIndex:idx].thumbnail;
    self.imageView.hidden = NO;
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.imageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // nothing
    }];
}

/** @brief @optional Informs the delegate that a data point was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 *  @param event The event that triggered the selection.
 **/
//-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event
//{
//    DLog(@"Plot %@ selected at index %d event %@", plot.identifier, idx, event);
//}

@end

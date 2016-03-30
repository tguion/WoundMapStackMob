//
//  WMPlotSelectDatasetViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//
//  Use WMWoundStatus + (NSArray *)graphableMeasurementTitles, then query WMWoundStatus to determine if there is data, and range of data
//  Then for WMPlotConfigureGraphViewController to pick the plots. e.g. For plot of Margins/Edges, plots for Regular,Irregular,Epithelization,Epibole,Attached,Loose
//  Other configurations for each plot may follow

#import "WMPlotSelectDatasetViewController.h"
#import "WMPlotConfigureGraphViewController.h"
#import "WMWound.h"
#import "WMWoundMeasurement.h"
#import "WMBradenScale.h"
#import "WoundStatusMeasurementRollup.h"
#import "WMCorePlotManager.h"

NSInteger kMinimumPointsForGraph = 2;

@interface WMPlotSelectDatasetViewController ()

@property (readonly, nonatomic) WMCorePlotManager *corePlotManager;

@property (strong, nonatomic) IBOutlet UIView *insufficientPlotDataView;
@property (strong, nonatomic) NSArray *graphableMeasurementTitles;      // Dimensions, Tissue in Wound, ..., add Braden Scale
@property (strong, nonatomic) NSMutableDictionary *wountStatusMeasurementTitle2RollupByKeyMapMap;
@property (strong, nonatomic) NSIndexPath *selectedRowAtIndexPath;
@property (readonly, nonatomic) WMPlotConfigureGraphViewController *plotConfigureGraphViewController;
@property (readonly, nonatomic) BOOL hasSufficientPlotData;

@end

@interface WMPlotSelectDatasetViewController (PrivateMethods)
- (NSInteger)numberMeasurementsForIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberMeasurementsForTitle:(NSString *)title;
- (void)updateUIForSelection;
- (void)showInsufficientPlotDataView;
- (void)hideInsufficientPlotDataView;
@end

@implementation WMPlotSelectDatasetViewController (PrivateMethods)

- (NSInteger)numberMeasurementsForIndexPath:(NSIndexPath *)indexPath
{
    return [self numberMeasurementsForTitle:[self.graphableMeasurementTitles objectAtIndex:indexPath.row]];
}

- (NSInteger)numberMeasurementsForTitle:(NSString *)title
{
    NSDictionary *key2RollupMap = [self.wountStatusMeasurementTitle2RollupByKeyMapMap objectForKey:title];
    NSInteger count = 0;
    for (NSString *key in key2RollupMap) {
        WoundStatusMeasurementRollup *rollup = [key2RollupMap objectForKey:key];
        if (rollup.valueCount >= kMinimumPointsForGraph) {
            ++count;
        }
    }
    return count;
}

- (void)updateUIForSelection
{
    self.navigationItem.rightBarButtonItem.enabled = ([self.selectedValues count] > 0 ? YES:NO);
}

- (void)showInsufficientPlotDataView
{
    if (nil != self.tableView.tableHeaderView) {
        return;
    }
    // else
    self.tableView.tableHeaderView = self.insufficientPlotDataView;
}

- (void)hideInsufficientPlotDataView
{
    if (nil == self.tableView.tableHeaderView) {
        return;
    }
    // else
    self.tableView.tableHeaderView = nil;
}

@end

@implementation WMPlotSelectDatasetViewController

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
    self.title = @"Select Data";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.allowMultipleSelection = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.hasSufficientPlotData) {
        [self hideInsufficientPlotDataView];
        [self.tableView reloadData];
    } else {
        [self showInsufficientPlotDataView];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // reset state
    _selectedRowAtIndexPath = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _graphableMeasurementTitles = nil;
    _wountStatusMeasurementTitle2RollupByKeyMapMap = nil;
}

// save data in any view before view goes away
- (void)preserveDataInViews
{
}

#pragma mark - Core

- (WMCorePlotManager *)corePlotManager
{
    return [WMCorePlotManager sharedInstance];
}

- (WMPlotConfigureGraphViewController *)plotConfigureGraphViewController
{
    WMPlotConfigureGraphViewController *plotConfigureGraphViewController = [[WMPlotConfigureGraphViewController alloc] initWithNibName:@"WMPlotConfigureGraphViewController" bundle:nil];
    plotConfigureGraphViewController.delegate = self.delegate;
    return plotConfigureGraphViewController;
}

- (NSArray *)graphableMeasurementTitles
{
    if (nil == _graphableMeasurementTitles) {
        _graphableMeasurementTitles = [[WMWoundMeasurement graphableMeasurementTitles] arrayByAddingObject:kBradenScaleTitle];
    }
    return _graphableMeasurementTitles;
}

// map for WMWoundMeasurement.title to map of key -> WoundStatusMeasurementRollup instances
- (NSMutableDictionary *)wountStatusMeasurementTitle2RollupByKeyMapMap
{
    if (nil == _wountStatusMeasurementTitle2RollupByKeyMapMap) {
        _wountStatusMeasurementTitle2RollupByKeyMapMap = [self.corePlotManager wountStatusMeasurementTitle2RollupByKeyMapMapForWound:self.wound
                                                                                                          graphableMeasurementTitles:self.graphableMeasurementTitles];
    }
    return _wountStatusMeasurementTitle2RollupByKeyMapMap;
}

- (BOOL)hasSufficientPlotData
{
    NSInteger count = 0;
    for (NSString *title in self.graphableMeasurementTitles) {
        count += [self numberMeasurementsForTitle:title];
    }
    return (count > 0);
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // no implementation
}

- (void)clearViewReferences
{
    [super clearViewReferences];
    _insufficientPlotDataView = nil;
}

- (void)clearDataCache
{
    [super clearDataCache];
    _wountStatusMeasurementTitle2RollupByKeyMapMap = nil;
    _selectedRowAtIndexPath = nil;
}

#pragma mark - Actions

- (IBAction)nextAction:(id)sender
{
    WMPlotConfigureGraphViewController *plotConfigureGraphViewController = self.plotConfigureGraphViewController;
    plotConfigureGraphViewController.wountStatusMeasurementTitle2RollupByKeyMapMap = self.wountStatusMeasurementTitle2RollupByKeyMapMap;
    plotConfigureGraphViewController.woundStatusMeasurementTitle = [self.selectedValues anyObject];
    [self.navigationController pushViewController:plotConfigureGraphViewController animated:YES];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate plotViewControllerDidCancel:self];
}

#pragma mark - PlotViewControllerDelegate

- (void)plotViewControllerDidCancel:(WMBaseViewController *)viewController
{
    // TODO clean up the stack
}

- (void)plotViewControllerDidFinish:(WMBaseViewController *)viewController
{
    // TODO clean up the stack
}

#pragma mark - UITableViewDelegate

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self numberMeasurementsForIndexPath:indexPath] == 0 ? nil:indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *woundStatusMeasurementTitle = [self.graphableMeasurementTitles objectAtIndex:indexPath.row];
    if ([self.selectedValues containsObject:woundStatusMeasurementTitle]) {
        [self.selectedValues removeObject:woundStatusMeasurementTitle];
    } else {
        [self.selectedValues removeAllObjects];
        [self.selectedValues addObject:woundStatusMeasurementTitle];
    }
    [self updateUIForSelection];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == self.managedObjectContext) {
        return 0;
    }
    // else
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.graphableMeasurementTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"WoundStatusMeasurementTitle";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *woundStatusMeasurementTitle = [self.graphableMeasurementTitles objectAtIndex:indexPath.row];
    NSInteger numberMeasurements = [self numberMeasurementsForIndexPath:indexPath];
    cell.textLabel.text = woundStatusMeasurementTitle;
    cell.textLabel.textColor = (numberMeasurements == 0 ? [UIColor lightGrayColor]:[UIColor blackColor]);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld plots", (long)numberMeasurements];
    if ([self.selectedValues containsObject:woundStatusMeasurementTitle]) {
        cell.imageView.image = [UIImage imageNamed:@"ui_checkmark"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"ui_circle"];
    }
}

@end

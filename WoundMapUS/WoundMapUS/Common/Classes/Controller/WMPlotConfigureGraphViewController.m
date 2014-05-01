//
//  WMPlotConfigureGraphViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//
//  If datasetSelection represents a WCWoundMeasurement, we need to allow the user to select the plots to include in the graph.
//  For example, if datasetSelection = "Margins/Edges", we need to user to select one or more of the following:
//  Regular,Irregular,Epithelization,Epibole,Attached,Loose
//  We should make sure that there is data for (Regular,Irregular,Epithelization,Epibole,Attached,Loose) elements, and only allow the
//  user to select those that have data
//
//  Show tableHeaderView with woundStatusMeasurement.title, or Braden Scales
//  cell for each key in woundStatusMeasurement
//  Section for dates: dateStart, dateEnd

#import "WMPlotConfigureGraphViewController.h"
#import "WMPlotSelectDatasetViewController.h"
#import "WMPlotGraphViewController.h"
#import "WoundStatusMeasurementRollup.h"
#import "WMWound.h"
#import "WMBradenScale.h"
#import "WMNavigationCoordinator.h"

NSTimeInterval timeInterval30Days = -60.0*60.0*24.0*30.0;

@interface WMPlotConfigureGraphViewController ()

@property (readonly, nonatomic) BOOL isSelectionBradenScales;
@property (strong, nonatomic) NSDate *dateStart;
@property (strong, nonatomic) NSDate *dateEnd;
@property (strong, nonatomic) NSMutableDictionary *key2RollupMap;       // selected WCWoundMeasurement.title or Braden Scale data
@property (strong, nonatomic) NSArray *rollups;                         // sorted rollups
@property (strong, nonatomic) NSDate *dateMinimum;                      // minimum date in all rollups
@property (strong, nonatomic) NSDate *dateMaximum;                      // maximum date in all rollups
@property (strong, nonatomic) IBOutlet UIView *datePickerContainer;     // container with date picker and toolbar
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;          // date picker
@property (nonatomic) BOOL updatingDateStart;                           // YES if updating dateStart
@property (readonly, nonatomic) WMPlotGraphViewController *plotGraphViewController;

- (WoundStatusMeasurementRollup *)woundStatusRollupForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)datePickerDidChangeValueAction:(id)sender;
- (IBAction)dismissDatePickerAction:(id)sender;
- (IBAction)previousNextAction:(id)sender;

@end

@interface WMPlotConfigureGraphViewController (PrivateMethods)
- (void)showDatePickerForCell:(UITableViewCell *)cell;
- (void)hideDatePicker;
- (void)selectDateCell;
- (void)updateUIForSelection;
@end

@implementation WMPlotConfigureGraphViewController (PrivateMethods)

- (void)showDatePickerForCell:(UITableViewCell *)cell
{
    if (nil != self.datePickerContainer.superview) {
        return;
    }
    // else
    [self.view addSubview:self.datePickerContainer];
    __block CGRect aFrame = self.datePickerContainer.frame;
    aFrame.origin.y = CGRectGetMaxY(self.view.bounds);
    self.datePickerContainer.frame = aFrame;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        aFrame.origin.y -= CGRectGetHeight(weakSelf.datePickerContainer.frame);
        weakSelf.datePickerContainer.frame = aFrame;
    } completion:^(BOOL finished) {
        // translate table
        weakSelf.keyboardMinY = CGRectGetHeight(weakSelf.view.bounds) - CGRectGetHeight(weakSelf.datePickerContainer.frame);
    }];
}

- (void)hideDatePicker
{
    if (nil == self.datePickerContainer.superview) {
        return;
    }
    // else
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect aFrame = weakSelf.datePickerContainer.frame;
        aFrame.origin.y = CGRectGetMaxY(weakSelf.view.bounds);
        weakSelf.datePickerContainer.frame = aFrame;
        // restore tableView transform
        weakSelf.tableView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [weakSelf.tableView deselectRowAtIndexPath:[weakSelf.tableView indexPathForSelectedRow] animated:NO];
        [weakSelf.datePickerContainer removeFromSuperview];
    }];
}

- (void)selectDateCell
{
    if (nil == self.datePickerContainer.superview) {
        return;
    }
    // else
    NSIndexPath *indexPath = nil;
    if (self.updatingDateStart) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    } else {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)updateUIForSelection
{
    self.navigationItem.rightBarButtonItem.enabled = ([self.selectedValues count] > 0 ? YES:NO);
}

@end

@implementation WMPlotConfigureGraphViewController

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
    self.title = @"Configure";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _key2RollupMap = nil;
    _rollups = nil;
    _dateMinimum = nil;
    _dateMaximum = nil;
}

// save data in any view before view goes away
- (void)preserveDataInViews
{
}

// clear any strong references to views
- (void)clearViewReferences
{
    [super clearViewReferences];
    _datePickerContainer = nil;
}

// TODO: fixme
- (void)viewDidUnload
{
    [super viewDidUnload];
    _datePickerContainer = nil;
}

#pragma mark - Core

- (BOOL)isSelectionBradenScales
{
    return [kBradenScaleTitle isEqualToString:_woundStatusMeasurementTitle];
}

- (NSDate *)dateStart
{
    if (nil == _dateStart) {
        _dateStart = self.dateMinimum;
    }
    return _dateStart;
}

- (NSDate *)dateEnd
{
    if (nil == _dateEnd) {
        _dateEnd = self.dateMaximum;
    }
    return _dateEnd;
}

- (NSDate *)dateMinimum
{
    if (nil == _dateMinimum) {
        _dateMinimum = [self.rollups valueForKeyPath:@"@min.dateMinimum"];
    }
    return _dateMinimum;
}

- (NSDate *)dateMaximum
{
    if (nil == _dateMaximum) {
        _dateMaximum = [self.rollups valueForKeyPath:@"@max.dateMaximum"];
    }
    return _dateMaximum;
}

- (NSDictionary *)key2RollupMap
{
    if (nil == _key2RollupMap) {
        _key2RollupMap = [self.wountStatusMeasurementTitle2RollupByKeyMapMap objectForKey:self.woundStatusMeasurementTitle];
    }
    return _key2RollupMap;
}

- (NSArray *)rollups
{
    if (nil == _rollups) {
        NSDictionary *map = self.key2RollupMap;
        NSMutableArray *rollups = (NSMutableArray *)[map allValues];
        [rollups sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
        _rollups = rollups;
    }
    return _rollups;
}

- (WoundStatusMeasurementRollup *)woundStatusRollupForIndexPath:(NSIndexPath *)indexPath;
{
    return (WoundStatusMeasurementRollup *)[self.rollups objectAtIndex:indexPath.row];
}

- (WMPlotGraphViewController *)plotGraphViewController
{
    WMPlotGraphViewController *plotGraphViewController = [[WMPlotGraphViewController alloc] initWithNibName:@"WMPlotGraphViewController" bundle:nil];
    plotGraphViewController.delegate = self.delegate;
    return plotGraphViewController;
}

#pragma mark - Actions

- (IBAction)datePickerDidChangeValueAction:(id)sender
{
    NSIndexPath *indexPath = nil;
    if (self.updatingDateStart) {
        self.dateStart = self.datePicker.date;
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    } else {
        self.dateEnd = self.datePicker.date;
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self performSelector:@selector(selectDateCell) withObject:nil afterDelay:0.0];
}

- (IBAction)previousNextAction:(id)sender
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    self.updatingDateStart = !self.updatingDateStart;
    NSIndexPath *indexPath = nil;
    if (self.updatingDateStart) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    } else {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    [self performSelector:@selector(selectDateCell) withObject:nil afterDelay:0.0];
}

- (IBAction)dismissDatePickerAction:(id)sender
{
    [self hideDatePicker];
}

// TODO: make sure self.plotGraphViewController is purged when done
- (IBAction)nextAction:(id)sender
{
    WMPlotGraphViewController *plotGraphViewController = self.plotGraphViewController;
    plotGraphViewController.woundStatusMeasurementTitle = self.woundStatusMeasurementTitle;
    plotGraphViewController.woundStatusMeasurementRollups = [self.selectedValues allObjects];
    plotGraphViewController.dateStart = self.dateStart;
    plotGraphViewController.dateEnd = self.dateEnd;
    if (self.isIPadIdiom) {
        // remove the popover and present the grapsh
        [self.delegate plotViewControllerDidFinish:self];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:plotGraphViewController];
        [(UIViewController *)self.delegate presentViewController:navigationController
                                                        animated:YES
                                                      completion:^{
                                                          // nothing
                                                      }];
    } else {
        [self.navigationController pushViewController:plotGraphViewController animated:YES];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate plotViewControllerDidCancel:self];
}

#pragma mark - UITableViewDelegate

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WoundStatusMeasurementRollup *woundStatusMeasurementRollup = [self woundStatusRollupForIndexPath:indexPath];
    return (0 == woundStatusMeasurementRollup.valueCount ? nil:indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            WoundStatusMeasurementRollup *woundStatusMeasurementRollup = [self woundStatusRollupForIndexPath:indexPath];
            if ([self.selectedValues containsObject:woundStatusMeasurementRollup]) {
                [self.selectedValues removeObject:woundStatusMeasurementRollup];
            } else {
                [self.selectedValues addObject:woundStatusMeasurementRollup];
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    self.updatingDateStart = YES;
                    self.datePicker.date = self.dateStart;
                    [self showDatePickerForCell:[tableView cellForRowAtIndexPath:indexPath]];
                    break;
                }
                case 1: {
                    self.updatingDateStart = NO;
                    self.datePicker.date = self.dateEnd;
                    [self showDatePickerForCell:[tableView cellForRowAtIndexPath:indexPath]];
                    break;
                }
            }
            break;
        }
    }
    [self updateUIForSelection];
    [self.tableView reloadData];
    [self performSelector:@selector(selectDateCell) withObject:nil afterDelay:0.0];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == self.managedObjectContext) {
        return 0;
    }
    // else
    return 2;
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            title = self.woundStatusMeasurementTitle;
            break;
        case 1:
            title = @"Dates";
            break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = [self.key2RollupMap count];
            break;
        case 1:
            count = 2;
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"RollupKeyCell";
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
    switch (indexPath.section) {
        case 0: {
            WoundStatusMeasurementRollup *woundStatusMeasurementRollup = [self woundStatusRollupForIndexPath:indexPath];
            cell.textLabel.text = woundStatusMeasurementRollup.key;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
            if (woundStatusMeasurementRollup.valueCount == 0) {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.text = @"(no data)";
            } else {
                cell.textLabel.textColor = [UIColor blackColor];
                NSString *minimumDateString = [NSDateFormatter localizedStringFromDate:woundStatusMeasurementRollup.dateMinimum dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                NSString *maximumDateString = [NSDateFormatter localizedStringFromDate:woundStatusMeasurementRollup.dateMaximum dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d values, (%@-%@)", woundStatusMeasurementRollup.valueCount, minimumDateString, maximumDateString];
            }
            if ([self.selectedValues containsObject:woundStatusMeasurementRollup]) {
                cell.imageView.image = [UIImage imageNamed:@"ui_checkmark.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"ui_circle.png"];
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    // date start
                    cell.textLabel.text = @"Start Date";
                    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.dateStart dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                    break;
                }
                case 1: {
                    // date end
                    cell.textLabel.text = @"End Date";
                    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.dateEnd dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                    break;
                }
            }
            break;
        }
    }
}

@end

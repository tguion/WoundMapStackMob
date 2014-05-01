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
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
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
@property (strong, nonatomic) UIDatePicker *datePicker;                 // date picker
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (nonatomic) BOOL updatingDateStart;                           // YES if updating dateStart
@property (readonly, nonatomic) WMPlotGraphViewController *plotGraphViewController;

- (WoundStatusMeasurementRollup *)woundStatusRollupForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)datePickerDidChangeValueAction:(id)sender;
- (IBAction)previousNextAction:(id)sender;

@end

@interface WMPlotConfigureGraphViewController (PrivateMethods)
- (void)selectDateCell;
- (void)updateUIForSelection;
@end

@implementation WMPlotConfigureGraphViewController (PrivateMethods)

- (void)selectDateCell
{
    NSIndexPath *indexPath = nil;
    if (self.updatingDateStart) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    } else {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    WMTextFieldTableViewCell *cell = (WMTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
}

- (void)updateUIForSelection
{
    self.navigationItem.rightBarButtonItem.enabled = ([self.selectedValues count] > 0 ? YES:NO);
}

@end

@implementation WMPlotConfigureGraphViewController

@synthesize inputAccessoryView=_inputAccessoryView;

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
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
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

#pragma mark - Core

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            cellIdentifier = @"ValueCell";
            break;
        }
        case 1: {
            cellIdentifier = @"TextCell";
            break;
        }
    }
    return cellIdentifier;
}

- (UIDatePicker *)datePicker
{
    if (nil == _datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    }
    return _datePicker;
}

- (UIToolbar *)inputAccessoryView
{
    if (nil == _inputAccessoryView) {
        // load the next/previous buttons
        _inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 44.0)];
        UIBarButtonItem *fixedWidthBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                                 target:nil
                                                                                                 action:NULL];
        fixedWidthBarButtonItem.width = 20.0;
        NSArray *barButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard_back"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(previousNextAction:)],
                                    fixedWidthBarButtonItem,
                                    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard_forward"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(previousNextAction:)],
                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:NULL],
                                    [[UIBarButtonItem alloc] initWithTitle:@"Dismiss"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismissAction:)]];
        _inputAccessoryView.items = barButtonItems;
    }
    return _inputAccessoryView;
}

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
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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

- (IBAction)dismissAction:(id)sender
{
    [self.view endEditing:YES];
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
                    break;
                }
                case 1: {
                    self.updatingDateStart = NO;
                    self.datePicker.date = self.dateEnd;
                    break;
                }
            }
            break;
        }
    }
    [self updateUIForSelection];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierForIndexPath:indexPath]];
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
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld values, (%@-%@)", (long)woundStatusMeasurementRollup.valueCount, minimumDateString, maximumDateString];
            }
            if ([self.selectedValues containsObject:woundStatusMeasurementRollup]) {
                cell.imageView.image = [UIImage imageNamed:@"ui_checkmark"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"ui_circle"];
            }
            break;
        }
        case 1: {
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            UITextField *textField = myCell.textField;
            textField.inputView = self.datePicker;
            textField.inputAccessoryView = self.inputAccessoryView;
            switch (indexPath.row) {
                case 0: {
                    // date start
                    [myCell updateWithLabelText:@"Start Date"
                                      valueText:[NSDateFormatter localizedStringFromDate:self.dateStart dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]
                                    valuePrompt:@"Enter Start Date"];
                    break;
                }
                case 1: {
                    // date end
                    [myCell updateWithLabelText:@"Start Date"
                                      valueText:[NSDateFormatter localizedStringFromDate:self.dateEnd dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]
                                    valuePrompt:@"Enter Start Date"];
                    break;
                }
            }
            break;
        }
    }
}

@end

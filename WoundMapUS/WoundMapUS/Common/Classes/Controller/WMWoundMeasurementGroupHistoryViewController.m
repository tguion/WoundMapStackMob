//
//  WMWoundMeasurementGroupHistoryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundMeasurementGroupHistoryViewController.h"
#import "WMWoundMeasurementSummaryViewController.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementGroupTableViewCell.h"

@interface WMWoundMeasurementGroupHistoryViewController ()

@property (readonly, nonatomic) WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController;

@end

@interface WMWoundMeasurementGroupHistoryViewController (PrivateMethods)
- (void)navigateToWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup;
@end

@implementation WMWoundMeasurementGroupHistoryViewController (PrivateMethods)

- (void)navigateToWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup
{
    WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController = self.woundMeasurementSummaryViewController;
    woundMeasurementSummaryViewController.woundMeasurementGroup = woundMeasurementGroup;
    [self.navigationController pushViewController:woundMeasurementSummaryViewController animated:YES];
}

@end

@implementation WMWoundMeasurementGroupHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.preferredContentSize = CGSizeMake(320.0, 320.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Assessment History";
    [self.tableView registerClass:[WMWoundMeasurementGroupTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (nil == self.navigationController) {
        [self clearAllReferences];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // no
}

- (void)fetchedResultsControllerDidFetch
{
    self.preferredContentSize = CGSizeMake(320.0, [self.fetchedResultsController.fetchedObjects count] * 44.0);
}

#pragma mark - Core

- (WMWoundMeasurementSummaryViewController *)woundMeasurementSummaryViewController
{
    return [[WMWoundMeasurementSummaryViewController alloc] initWithNibName:@"WMWoundMeasurementSummaryViewController" bundle:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMWoundMeasurementGroup *woundMeasurementGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToWoundMeasurementGroup:woundMeasurementGroup];
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMWoundMeasurementGroup *woundMeasurementGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMWoundMeasurementGroupTableViewCell *myCell = (WMWoundMeasurementGroupTableViewCell *)cell;
    myCell.woundMeasurementGroup = woundMeasurementGroup;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    return @[[NSString stringWithFormat:@"%@/%@", self.wound.ffUrl, WMWoundRelationships.measurementGroups]];
}

- (id)aggregator
{
    return self.wound;
}

- (NSString *)fetchedResultsControllerEntityName
{
	return [WMWoundMeasurementGroup entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"wound == %@ AND (status.activeFlag == NO OR closedFlag == YES)", self.wound];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
}

@end

//
//  WMWoundTreatmentGroupsViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWoundTreatmentGroupsViewController.h"
#import "WMWoundTreatmentViewController.h"
#import "WMWoundTreatmentSummaryViewController.h"
#import "WMWound.h"
#import "WMWoundTreatmentGroup.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMWoundTreatmentGroupsViewController () <WoundTreatmentViewControllerDelegate>

@property (readonly, nonatomic) WMWoundTreatmentViewController *woundTreatmentViewController;
@property (readonly, nonatomic) WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController;
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;

@end

@interface WMWoundTreatmentGroupsViewController (PrivateMethods)
- (void)navigateToWoundTreatmentViewController:(WMWoundTreatmentGroup *)woundTreatmentGroup;
@end

@implementation WMWoundTreatmentGroupsViewController (PrivateMethods)

- (void)navigateToWoundTreatmentViewController:(WMWoundTreatmentGroup *)woundTreatmentGroup
{
    WMWoundTreatmentViewController *woundTreatmentViewController = self.woundTreatmentViewController;
    woundTreatmentViewController.woundTreatmentGroup = woundTreatmentGroup;
    [self.navigationController pushViewController:woundTreatmentViewController animated:YES];
}

@end

@implementation WMWoundTreatmentGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Treatments";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAction:)];
    self.tableView.tableFooterView = _tableFooterView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - Core

- (WMWoundTreatmentViewController *)woundTreatmentViewController
{
    WMWoundTreatmentViewController *woundTreatmentViewController = [[WMWoundTreatmentViewController alloc] initWithNibName:@"WMWoundTreatmentViewController" bundle:nil];
    woundTreatmentViewController.delegate = self;
    return woundTreatmentViewController;
}

- (WMWoundTreatmentSummaryViewController *)woundTreatmentSummaryViewController
{
    return [[WMWoundTreatmentSummaryViewController alloc] initWithNibName:@"WMWoundTreatmentSummaryViewController" bundle:nil];
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.delegate woundTreatmentGroupsViewControllerDidFinish:self];
}

- (IBAction)addAction:(id)sender
{
    [self navigateToWoundTreatmentViewController:nil];
}

#pragma mark - WoundTreatmentViewControllerDelegate

- (void)woundTreatmentViewController:(WMWoundTreatmentViewController *)viewController willDeleteWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
{
}

- (void)woundTreatmentViewControllerDidFinish:(WMWoundTreatmentViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)woundTreatmentViewControllerDidCancel:(WMWoundTreatmentViewController *)viewController
{
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // edit group
    WMWoundTreatmentGroup *woundTreatmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (woundTreatmentGroup.isClosed || !woundTreatmentGroup.status.isActive) {
        // go to viewer, not editor
        WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController = self.woundTreatmentSummaryViewController;
        woundTreatmentSummaryViewController.woundTreatmentGroup = woundTreatmentGroup;
        [self.navigationController pushViewController:woundTreatmentSummaryViewController animated:YES];
    } else {
        [self navigateToWoundTreatmentViewController:woundTreatmentGroup];
    }
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMWoundTreatmentGroup *woundTreatmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    NSInteger count = [woundTreatmentGroup.values count];
    NSString *treatmentSuffix = (count == 1 ? @"treatment":@"treatments");
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %d %@",
                           [NSDateFormatter localizedStringFromDate:woundTreatmentGroup.createdAt dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle],
                           count,
                           treatmentSuffix];
    if (woundTreatmentGroup.isClosed) {
        cell.detailTextLabel.text = @"closed";
    } else {
        cell.detailTextLabel.text = nil;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    return [NSString stringWithFormat:@"%@/%@", self.wound.ffUrl, WMWoundRelationships.treatmentGroups];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMWoundTreatmentGroup";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"wound == %@", self.wound];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:WMWoundTreatmentGroupAttributes.createdAt ascending:NO]];
}

@end

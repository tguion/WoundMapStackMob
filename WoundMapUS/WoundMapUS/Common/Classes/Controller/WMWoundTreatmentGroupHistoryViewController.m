//
//  WMWoundTreatmentGroupHistoryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundTreatmentGroupHistoryViewController.h"
#import "WMWoundTreatmentSummaryViewController.h"
#import "WMWound.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentGroupTableViewCell.h"

@interface WMWoundTreatmentGroupHistoryViewController ()

@property (readonly, nonatomic) WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController;

@end

@interface WMWoundTreatmentGroupHistoryViewController (PrivateMethods)
- (void)navigateToWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup;
@end

@implementation WMWoundTreatmentGroupHistoryViewController (PrivateMethods)

- (void)navigateToWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
{
    WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController = self.woundTreatmentSummaryViewController;
    woundTreatmentSummaryViewController.woundTreatmentGroup = woundTreatmentGroup;
    [self.navigationController pushViewController:woundTreatmentSummaryViewController animated:YES];
}

@end

@implementation WMWoundTreatmentGroupHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Treatment History";
    [self.tableView registerClass:[WMWoundTreatmentGroupTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (nil == self.navigationController) {
        [self clearAllReferences];
    }
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // no
}

#pragma mark - Core

- (WMWoundTreatmentSummaryViewController *)woundTreatmentSummaryViewController
{
    return [[WMWoundTreatmentSummaryViewController alloc] initWithNibName:@"WMWoundTreatmentSummaryViewController" bundle:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMWoundTreatmentGroup *woundTreatmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToWoundTreatmentGroup:woundTreatmentGroup];
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
    WMWoundTreatmentGroup *woundTreatmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMWoundTreatmentGroupTableViewCell *myCell = (WMWoundTreatmentGroupTableViewCell *)cell;
    myCell.woundTreatmentGroup = woundTreatmentGroup;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    return [NSPredicate predicateWithFormat:@"patient == %@ AND (status.activeFlag == NO OR closedFlag == YES)", self.patient];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
}

@end

//
//  WMCarePlanGroupHistoryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCarePlanGroupHistoryViewController.h"
#import "WMCarePlanSummaryViewController.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanGroupTableViewCell.h"

@interface WMCarePlanGroupHistoryViewController ()

@property (readonly, nonatomic) WMCarePlanSummaryViewController *carePlanSummaryViewController;

@end

@interface WMCarePlanGroupHistoryViewController (PrivateMethods)
- (void)navigateToCarePlanGroup:(WMCarePlanGroup *)carePlanGroup;
@end

@implementation WMCarePlanGroupHistoryViewController (PrivateMethods)

- (void)navigateToCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
{
    WMCarePlanSummaryViewController *carePlanSummaryViewController = self.carePlanSummaryViewController;
    carePlanSummaryViewController.carePlanGroup = carePlanGroup;
    carePlanSummaryViewController.automaticallyAdjustsScrollViewInsets = YES;
    [self.navigationController pushViewController:carePlanSummaryViewController animated:YES];
}

@end

@implementation WMCarePlanGroupHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Care Plan History";
    [self.tableView registerClass:[WMCarePlanGroupTableViewCell class] forCellReuseIdentifier:@"Cell"];
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

#pragma mark - Core

- (WMCarePlanSummaryViewController *)carePlanSummaryViewController
{
    return [[WMCarePlanSummaryViewController alloc] initWithNibName:@"WMCarePlanSummaryViewController" bundle:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMCarePlanGroup *carePlanGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToCarePlanGroup:carePlanGroup];
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
    WMCarePlanGroup *carePlanGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMCarePlanGroupTableViewCell *myCell = (WMCarePlanGroupTableViewCell *)cell;
    myCell.carePlanGroup = carePlanGroup;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMCarePlanGroup";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"status.activeFlag == NO OR closedFlag == YES"];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:WMCarePlanGroupAttributes.updatedAt ascending:NO]];
}

@end

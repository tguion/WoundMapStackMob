//
//  WMDevicesGroupHistoryViewContoller.m
//  WoundMAP
//
//  Created by Todd Guion on 12/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMDevicesGroupHistoryViewContoller.h"
#import "WMDevicesSummaryViewController.h"
#import "WMDevicesGroupTableViewCell.h"
#import "WMDeviceGroup.h"

@interface WMDevicesGroupHistoryViewContoller ()
@property (readonly, nonatomic) WMDevicesSummaryViewController *devicesSummaryViewController;
@end

@interface WMDevicesGroupHistoryViewContoller (PrivateMethods)
- (void)navigateToDevicesGroup:(WMDeviceGroup *)deviceGroup;
@end

@implementation WMDevicesGroupHistoryViewContoller (PrivateMethods)

- (void)navigateToDevicesGroup:(WMDeviceGroup *)deviceGroup
{
    WMDevicesSummaryViewController *devicesSummaryViewController = self.devicesSummaryViewController;
    devicesSummaryViewController.devicesGroup = deviceGroup;
    [self.navigationController pushViewController:devicesSummaryViewController animated:YES];
}

@end

@implementation WMDevicesGroupHistoryViewContoller

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Devices History";
    [self.tableView registerClass:[WMDevicesGroupTableViewCell class] forCellReuseIdentifier:@"Cell"];
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

#pragma mark - BaseViewController

- (void)updateTitle
{
    // no
}

#pragma mark - Core

- (WMDevicesSummaryViewController *)devicesSummaryViewController
{
    return [[WMDevicesSummaryViewController alloc] initWithNibName:@"WMDevicesSummaryViewController" bundle:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMDeviceGroup *devicesGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToDevicesGroup:devicesGroup];
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
    WMDeviceGroup *devicesGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMDevicesGroupTableViewCell *myCell = (WMDevicesGroupTableViewCell *)cell;
    myCell.devicesGroup = devicesGroup;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMDeviceGroup";
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

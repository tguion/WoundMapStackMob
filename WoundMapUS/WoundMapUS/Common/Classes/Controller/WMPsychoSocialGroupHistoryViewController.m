//
//  WMPsychoSocialGroupHistoryViewController.m
//  WoundMAP
//
//  Created by Todd Guion on 11/26/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMPsychoSocialGroupHistoryViewController.h"
#import "WMPsychoSocialSummaryViewController.h"
#import "WMPsychoSocialGroupTableViewCell.h"
#import "WMPatient.h"
#import "WMPsychoSocialGroup.h"

@interface WMPsychoSocialGroupHistoryViewController ()

@property (readonly, nonatomic) WMPsychoSocialSummaryViewController *psychoSocialSummaryViewController;

@end

@interface WMPsychoSocialGroupHistoryViewController (PrivateMethods)
- (void)navigateToPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup;
@end

@implementation WMPsychoSocialGroupHistoryViewController (PrivateMethods)

- (void)navigateToPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
{
    WMPsychoSocialSummaryViewController *psychoSocialSummaryViewController = self.psychoSocialSummaryViewController;
    psychoSocialSummaryViewController.psychoSocialGroup = psychoSocialGroup;
    [self.navigationController pushViewController:psychoSocialSummaryViewController animated:YES];
}

@end

@implementation WMPsychoSocialGroupHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"PsychoSocial History";
    [self.tableView registerClass:[WMPsychoSocialGroupTableViewCell class] forCellReuseIdentifier:@"Cell"];
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

- (WMPsychoSocialSummaryViewController *)psychoSocialSummaryViewController
{
    return [[WMPsychoSocialSummaryViewController alloc] initWithNibName:@"WMPsychoSocialSummaryViewController" bundle:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMPsychoSocialGroup *psychoSocialGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToPsychoSocialGroup:psychoSocialGroup];
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
    WMPsychoSocialGroup *psychoSocialGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMPsychoSocialGroupTableViewCell *myCell = (WMPsychoSocialGroupTableViewCell *)cell;
    myCell.psychoSocialGroup = psychoSocialGroup;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    return @[[NSString stringWithFormat:@"%@/%@", self.patient.ffUrl, WMPatientRelationships.psychosocialGroups]];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMPsychoSocialGroup";
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

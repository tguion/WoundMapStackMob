//
//  WMSkinAssessmentGroupHistoryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSkinAssessmentGroupHistoryViewController.h"
#import "WMSkinAssessmentSummaryViewController.h"
#import "WMPatient.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentGroupTableViewCell.h"

@interface WMSkinAssessmentGroupHistoryViewController ()

@property (readonly, nonatomic) WMSkinAssessmentSummaryViewController *skinAssessmentSummaryViewController;

@end

@interface WMSkinAssessmentGroupHistoryViewController (PrivateMethods)
- (void)navigateToSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup;
@end

@implementation WMSkinAssessmentGroupHistoryViewController (PrivateMethods)

- (void)navigateToSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
{
    WMSkinAssessmentSummaryViewController *skinAssessmentSummaryViewController = self.skinAssessmentSummaryViewController;
    skinAssessmentSummaryViewController.skinAssessmentGroup = skinAssessmentGroup;
    [self.navigationController pushViewController:skinAssessmentSummaryViewController animated:YES];
}

@end

@implementation WMSkinAssessmentGroupHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Skin Assessment History";
    [self.tableView registerClass:[WMSkinAssessmentGroupTableViewCell class] forCellReuseIdentifier:@"Cell"];
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

- (WMSkinAssessmentSummaryViewController *)skinAssessmentSummaryViewController
{
    return [[WMSkinAssessmentSummaryViewController alloc] initWithNibName:@"WMSkinAssessmentSummaryViewController" bundle:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMSkinAssessmentGroup *skinAssessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToSkinAssessmentGroup:skinAssessmentGroup];
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
    WMSkinAssessmentGroup *skinAssessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMSkinAssessmentGroupTableViewCell *myCell = (WMSkinAssessmentGroupTableViewCell *)cell;
    myCell.skinAssessmentGroup = skinAssessmentGroup;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    return @[[NSString stringWithFormat:@"%@/%@", self.patient.ffUrl, WMPatientRelationships.skinAssessmentGroups]];
}

- (id)aggregator
{
    return self.patient;
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMSkinAssessmentGroup";
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

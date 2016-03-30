//
//  WMMedicationGroupHistoryViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMMedicationGroupHistoryViewController.h"
#import "WMMedicationSummaryViewController.h"
#import "WMPatient.h"
#import "WMMedicationGroup.h"
#import "WMMedicationGroupTableViewCell.h"

@interface WMMedicationGroupHistoryViewController ()

@property (readonly, nonatomic) WMMedicationSummaryViewController *medicationSummaryViewController;

@end

@interface WMMedicationGroupHistoryViewController (PrivateMethods)
- (void)navigateToMedicationGroup:(WMMedicationGroup *)medicationGroup;
@end

@implementation WMMedicationGroupHistoryViewController (PrivateMethods)

- (void)navigateToMedicationGroup:(WMMedicationGroup *)medicationGroup
{
    WMMedicationSummaryViewController *medicationSummaryViewController = self.medicationSummaryViewController;
    medicationSummaryViewController.medicationGroup = medicationGroup;
    [self.navigationController pushViewController:medicationSummaryViewController animated:YES];
}

@end

@implementation WMMedicationGroupHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Medication History";
    [self.tableView registerClass:[WMMedicationGroupTableViewCell class] forCellReuseIdentifier:@"Cell"];
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

#pragma mark - Core

- (WMMedicationSummaryViewController *)medicationSummaryViewController
{
    return [[WMMedicationSummaryViewController alloc] initWithNibName:@"WMMedicationSummaryViewController" bundle:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMMedicationGroup *medicationGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToMedicationGroup:medicationGroup];
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
    WMMedicationGroup *medicationGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMMedicationGroupTableViewCell *myCell = (WMMedicationGroupTableViewCell *)cell;
    myCell.medicationGroup = medicationGroup;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    return @[[NSString stringWithFormat:@"%@/%@", self.patient.ffUrl, WMPatientRelationships.medicationGroups]];
}

- (id)aggregator
{
    return self.patient;
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMMedicationGroup";
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

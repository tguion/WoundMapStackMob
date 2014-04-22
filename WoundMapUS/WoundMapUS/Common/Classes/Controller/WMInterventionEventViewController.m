//
//  WMInterventionEventViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMInterventionEventViewController.h"
#import "WMEventTableViewCell.h"
#import "WMInterventionEvent.h"
#import "WMMedicationGroup.h"
#import "WMSkinAssessmentGroup.h"
#import "WMCarePlanGroup.h"
#import "WMDeviceGroup.h"
#import "WMPsychoSocialGroup.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundTreatmentGroup.h"

@interface WMInterventionEventViewController ()
@property (strong, nonatomic) NSString *keyName;
@end

@implementation WMInterventionEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Events";
    // TODO: finish the filter
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
//                                                                             style:UIBarButtonItemStyleBordered
//                                                                            target:self
//                                                                            action:@selector(filterAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // clear our cache
    [self clearAllReferences];
}

#pragma mark - Memory

- (void)clearDataCache
{
    [super clearDataCache];
    _assessmentGroup = nil;
    _keyName = nil;
}

#pragma mark - Core

- (id<AssessmentGroup>)assessmentGroup
{
    if (nil == _assessmentGroup) {
        _assessmentGroup = self.delegate.assessmentGroup;
    }
    return _assessmentGroup;
}

- (NSString *)keyName
{
    if (nil == _keyName) {
        if ([self.assessmentGroup isKindOfClass:[WMMedicationGroup class]]) {
            _keyName = @"medicationGroup";
        } else if ([self.assessmentGroup isKindOfClass:[WMSkinAssessmentGroup class]]) {
            _keyName = @"skinAssessmentGroup";
        } else if ([self.assessmentGroup isKindOfClass:[WMCarePlanGroup class]]) {
            _keyName = @"carePlanGroup";
        } else if ([self.assessmentGroup isKindOfClass:[WMDeviceGroup class]]) {
            _keyName = @"deviceGroup";
        } else if ([self.assessmentGroup isKindOfClass:[WMPsychoSocialGroup class]]) {
            _keyName = @"psychoSocialGroup";
        } else if ([self.assessmentGroup isKindOfClass:[WMWoundMeasurementGroup class]]) {
            _keyName = @"measurementGroup";
        } else if ([self.assessmentGroup isKindOfClass:[WMWoundTreatmentGroup class]]) {
            _keyName = @"treatmentGroup";
        }
    }
    return _keyName;
}

#pragma mark - Actions

- (IBAction)filterAction:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TBD"
                                                        message:@"This feature in under construction"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate interventionEventViewControllerDidCancel:self];
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // no
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WMEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMEventTableViewCell *myCell = (WMEventTableViewCell *)cell;
    myCell.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return [WMInterventionEvent entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"%K == %@", self.keyName, self.assessmentGroup];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateEvent" ascending:NO]];
}

@end

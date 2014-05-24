//
//  WMInterventionStatusViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMInterventionStatusViewController.h"
#import "WMInterventionStatus.h"
#import "WMInterventionStatusJoin.h"
#import "WMDesignUtilities.h"

@interface WMInterventionStatusViewController ()

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (nonatomic) BOOL selectedInterventionStatusHasChangedFlag;
@property (strong, nonatomic) NSManagedObjectID *selectedInterventionStatusID;
@property (nonatomic) BOOL didCancel;

- (IBAction)cancelAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

@interface WMInterventionStatusViewController (PrivateMethods)
- (void)updateUIForDataChange;
@end

@implementation WMInterventionStatusViewController (PrivateMethods)

- (void)updateUIForDataChange
{
    if (self.selectedInterventionStatusHasChangedFlag) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelAction:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self
                                                                                               action:@selector(doneAction:)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(doneAction:)];
    }
}

@end

@implementation WMInterventionStatusViewController

@synthesize delegate, selectedInterventionStatus=_selectedInterventionStatus, selectedInterventionStatusID=_selectedInterventionStatusID;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Select Status";
    // toolbar to show summary
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithTitle:self.delegate.summaryButtonTitle
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(presentSummaryAction:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"Continue as Planned"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(continueAction:)],
                         nil];
    // we want to support cancel, so make sure we have an undoManager
    if (nil == self.managedObjectContext.undoManager) {
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        _removeUndoManagerWhenDone = YES;
    }
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIForDataChange];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    if (nil != _selectedInterventionStatus && ![[_selectedInterventionStatus objectID] isTemporaryID]) {
        _selectedInterventionStatusID = [_selectedInterventionStatus objectID];
        _selectedInterventionStatus = nil;
    }
}

// save data in any view before view goes away
- (void)preserveDataInViews
{
}

- (void)clearDataCache
{
    [super clearDataCache];
    _selectedInterventionStatusID = nil;
    _selectedInterventionStatus = nil;
}

#pragma mark - Core

- (WMInterventionStatus *)selectedInterventionStatus
{
    if (nil == _selectedInterventionStatus) {
        self.selectedInterventionStatus = self.delegate.selectedInterventionStatus;
    }
    return _selectedInterventionStatus;
}

- (void)setSelectedInterventionStatus:(WMInterventionStatus *)selectedInterventionStatus
{
    self.selectedInterventionStatusHasChangedFlag = (selectedInterventionStatus != self.delegate.selectedInterventionStatus);
    if (_selectedInterventionStatus == selectedInterventionStatus) {
        return;
    }
    // else
    [self willChangeValueForKey:@"selectedInterventionStatus"];
    _selectedInterventionStatus = selectedInterventionStatus;
    [self didChangeValueForKey:@"selectedInterventionStatus"];
}

#pragma mark - Actions

- (IBAction)presentSummaryAction:(id)sender
{
    [self.navigationController pushViewController:self.delegate.summaryViewController animated:YES];
}

- (IBAction)continueAction:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self.delegate.assessmentGroup respondsToSelector:@selector(incrementContinueCount)]) {
        [self.delegate.assessmentGroup performSelector:@selector(incrementContinueCount)];
        [self updateUIForDataChange];
    }
#pragma clang diagnostic pop
}

- (IBAction)doneAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate interventionStatusViewController:self didSelectInterventionStatus:self.selectedInterventionStatus];
}

- (IBAction)cancelAction:(id)sender
{
    _didCancel = YES;
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    [self.delegate interventionStatusViewControllerDidCancel:self];
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMInterventionStatus *interventionStatus = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.selectedInterventionStatus canUpdateToStatus:interventionStatus]) {
        return indexPath;
    }
    // else
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedInterventionStatus = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self updateUIForDataChange];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMInterventionStatus *interventionStatus = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = interventionStatus.title;
    cell.textLabel.textColor = ([self.selectedInterventionStatus canUpdateToStatus:interventionStatus] ? [UIColor blackColor]:[UIColor lightGrayColor]);
    if (interventionStatus == self.selectedInterventionStatus) {
        cell.imageView.image = [WMDesignUtilities selectedWoundTableCellImage];
    } else {
        cell.imageView.image = [WMDesignUtilities unselectedWoundTableCellImage];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - NSFetchedResultsController

- (NSArray *)backendSeedEntityNames
{
    return @[];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMInterventionStatus";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return nil;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
}

@end

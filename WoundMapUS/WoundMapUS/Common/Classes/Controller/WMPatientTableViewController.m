//
//  WMPatientTableViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//
//  ISSUE: advanced predicates are not supported on StackMob server at this time.
//  So we switch to cache only fetch. However, the properties of WMPatient and WMPatientConsult are not being synched on local cache.

#import "WMPatientTableViewController.h"
#import "WMPatientTableViewCell.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

#define kPatientTableViewCellHeight 76.0

#define kDeletePatientConfirmAlertTag 2004

@interface WMPatientTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *patientTypeContainerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *patientTypeSegmentedControl;
@property (readonly, nonatomic) BOOL isShowingTeamPatients;
@property (strong, nonatomic) WMPatient *patientToDelete;
@property (strong, nonatomic) WMPatient *patientToOpen;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIView *searchBarTextField;

- (IBAction)patientTypeValueChangedAction:(id)sender;

@end

@interface WMPatientTableViewController (PrivateMethods)
- (void)updateUIForPatientList;
- (void)deletePatient:(WMPatient *)patient;
@end

@implementation WMPatientTableViewController (PrivateMethods)

- (void)updateUIForPatientList
{
    if ([self.fetchedResultsController.fetchedObjects count] > 0) {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)deletePatient:(WMPatient *)patient
{
    __weak __typeof(self) weakSelf = self;
    [self.appDelegate.navigationCoordinator deletePatient:patient completionHandler:^{
        [weakSelf updateUIForPatientList];
        [weakSelf.tableView reloadData];
    }];
}

@end

@implementation WMPatientTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // popover
        self.preferredContentSize = CGSizeMake(320.0, 1000.0);
        self.modalInPopover = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Patients", @"Patients");
    self.navigationItem.hidesBackButton = YES;
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.hidesBackButton = YES;
    [self.tableView registerClass:[WMPatientTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.searchDisplayController.searchResultsTableView registerClass:[WMPatientTableViewCell class] forCellReuseIdentifier:@"SearchCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // show progress
    [self showProgressViewWithMessage:@"Acquiring Patient Records"];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __weak __typeof(self) weakSelf = self;
    [ffm fetchPatients:self.managedObjectContext ff:ff completionHandler:^(NSError *error) {
        [weakSelf hideProgressView];
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (BOOL)isShowingTeamPatients
{
    return _patientTypeSegmentedControl.selectedSegmentIndex == 0;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.delegate patientTableViewController:self didSelectPatient:_patientToOpen];
}

// WMPatientConsultant is fetched from server, but properties are not populated
- (IBAction)patientTypeValueChangedAction:(id)sender
{
    [self refetchDataForTableView];
}

#pragma mark - Notification handlers

#pragma mark - WMBaseViewController

- (void)clearViewReferences
{
    [super clearViewReferences];
    _patientTypeContainerView = nil;
    _patientTypeSegmentedControl = nil;
}

- (void)clearDataCache
{
    [super clearDataCache];
    _patientToDelete = nil;
    _patientToOpen = nil;
}

- (void)fetchedResultsControllerDidFetch
{
    [self updateUIForPatientList];
    CGFloat height = fmaxf(360.0, [self.fetchedResultsController.fetchedObjects count] * kPatientTableViewCellHeight + CGRectGetHeight(self.tableView.tableHeaderView.frame));
    self.preferredContentSize = CGSizeMake(320.0, height);
}

#pragma mark - UIViewController

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
    if (editing) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(doneAction:)];
    }
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeletePatientConfirmAlertTag) {
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            [self deletePatient:_patientToDelete];
            _patientToDelete = nil;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.navigationItem.leftBarButtonItem = nil;
    if (self.navigationItem.rightBarButtonItem.target == self) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    searchBar.showsCancelButton = YES;
    self.navigationItem.hidesBackButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [self refetchDataForTableView];
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self refetchDataForTableView];
}

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)viewController shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString length] > 0) {
        [self refetchDataForTableView];
        return YES;
    }
    // else
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)viewController shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self refetchDataForTableView];
    return YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPatientTableViewCellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (tableView == self.tableView);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete the document and local cache after confirm
        _patientToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm delete patient from all devices"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete Patient"
                                                        otherButtonTitles:nil];
        actionSheet.tag = kDeletePatientConfirmAlertTag;
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // let done/cancel action do the work
    if (self.isShowingTeamPatients) {
        _patientToOpen = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        _patientToOpen = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:WMPatientConsultantRelationships.patient];
    }
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cellIdentifier = @"SearchCell";
    } else {
        cellIdentifier = @"Cell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (WMPatient *)patientAtIndexPath:(NSIndexPath *)indexPath
{
    WMPatient *patient = nil;
    if (self.isShowingTeamPatients) {
        patient = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        patient = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:WMPatientConsultantRelationships.patient];
    }
    return patient;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMPatient *patient = [self patientAtIndexPath:indexPath];
    cell.accessoryType = ([patient isEqual:_patientToOpen] ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
    WMPatientTableViewCell *myCell = (WMPatientTableViewCell *)cell;
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.isShowingTeamPatients) {
        myCell.patient = object;
    } else {
        myCell.patientConsultant = object;
    }
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    if (self.isShowingTeamPatients) {
        return [WMPatient entityName];
    }
    // else
    return [WMPatientConsultant entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isShowingTeamPatients) {
        if (self.isSearchActive) {
            NSString *searchText = self.searchDisplayController.searchBar.text;
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                           [NSPredicate predicateWithFormat:@"person.nameFamily CONTAINS[cd] %@", searchText],
                                                                           [NSPredicate predicateWithFormat:@"person.nameGiven CONTAINS[cd] %@", searchText],
                                                                           [NSPredicate predicateWithFormat:@"ids.extension CONTAINS[cd] %@", searchText],
                                                                           nil]];
        }
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
}

@end

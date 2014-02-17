//
//  WMPatientTableViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientTableViewController.h"
#import "WMPatientTableViewCell.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"
#import "StackMob.h"

#define kPatientTableViewCellHeight 76.0

#define kDeletePatientConfirmAlertTag 2004

@interface WMPatientTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *patientTypeContainerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *patientTypeSegmentedControl;
@property (readonly, nonatomic) BOOL isShowingTeamPatients;
@property (strong, nonatomic) WMPatient *patientToDelete;
@property (strong, nonatomic) WMPatient *patientToOpen;
@property (nonatomic) BOOL waitingForSynchWithServer;

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
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    [managedObjectContext deleteObject:patient];
    __weak __typeof(self) weakSelf = self;
    [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
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
    [self.tableView registerClass:[WMPatientTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.searchDisplayController.searchResultsTableView registerClass:[WMPatientTableViewCell class] forCellReuseIdentifier:@"SearchCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fetchPolicy = SMFetchPolicyCacheOnly;
    _patientToOpen = self.patient;
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
    // mark that we are waiting for synch to complete
    _waitingForSynchWithServer = YES;
    // reconnect to network
    self.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    // show progress
    [self showProgressViewWithMessage:@"Updating Patient Record"];
    // synchronize with StackMob and wait for callback
    [self.coreDataHelper.stackMobStore syncWithServer];
}

- (IBAction)patientTypeValueChangedAction:(id)sender
{
    [self refetchDataForTableView];
}

#pragma mark - Notification handlers

// network synch with server has finished - subclasses may need to override
- (void)handleStackMobNetworkSynchFinished:(NSNotification *)notification
{
    [self hideProgressView];
    if (_waitingForSynchWithServer) {
        [super handleStackMobNetworkSynchFinished:notification];
        [self.delegate patientTableViewController:self didSelectPatient:_patientToOpen];
    }
}

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
    _waitingForSynchWithServer = NO;
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

//- (void)searchDisplayController:(UISearchDisplayController *)viewController willShowSearchResultsTableView:(UITableView *)tableView
//{
//    [tableView registerClass:[WMPatientTableViewCell class] forCellReuseIdentifier:@"SearchCell"];
//    self.tableView.hidden = YES;
//}

//- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
//{
//    self.tableView.hidden = NO;
//}

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
    _patientToOpen = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    cell.accessoryType = ([patient isEqual:self.patient] ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
    WMPatientTableViewCell *myCell = (WMPatientTableViewCell *)cell;
    myCell.patient = patient;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    if (self.isShowingTeamPatients) {
        return @"WMPatient";
    }
    // else
    return @"WMPatientConsultant";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        NSString *searchText = self.searchDisplayController.searchBar.text;
        if (self.isShowingTeamPatients) {
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                           [NSPredicate predicateWithFormat:@"person.nameFamily CONTAINS[cd] %@", searchText],
                                                                           [NSPredicate predicateWithFormat:@"person.nameGiven CONTAINS[cd] %@", searchText],
                                                                           [NSPredicate predicateWithFormat:@"ids.extension CONTAINS[cd] %@", searchText],
                                                                           nil]];
        } else {
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                           [NSPredicate predicateWithFormat:@"patient.person.nameFamily CONTAINS[cd] %@", searchText],
                                                                           [NSPredicate predicateWithFormat:@"patient.person.nameGiven CONTAINS[cd] %@", searchText],
                                                                           [NSPredicate predicateWithFormat:@"patient.ids.extension CONTAINS[cd] %@", searchText],
                                                                           nil]];
        }
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastmoddate" ascending:NO]];
}

@end

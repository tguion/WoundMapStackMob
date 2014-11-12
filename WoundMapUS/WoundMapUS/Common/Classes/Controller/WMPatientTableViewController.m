//
//  WMPatientTableViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//
/*
 // Above ios 8.0
 float os_version = [[[UIDevice currentDevice] systemVersion] floatValue];
 if (os_version >= 8.000000)
 {
 　　　//Use UISearchController
 // self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
 }
 else
 {
 //use UISearchDisaplyController
 // self.controller = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
 
 }
 */

#import "WMPatientTableViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMPatientSummaryContainerViewController.h"
#import "WMPatientReferralViewController.h"
#import "WMPatientAutoTableViewCell.h"
#import "MBProgressHUD.h"
#import "WMparticipant.h"
#import "WMTeam.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "WMPatientReferral.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMNavigationCoordinator.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"

#define kPatientTableViewCellHeight 76.0

#define kDeletePatientConfirmAlertTag 2004

@interface WMPatientTableViewController () <PatientDetailViewControllerDelegate, PatientSummaryContainerDelegate, PatientReferralDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *patientTypeContainerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *patientTypeSegmentedControl;
@property (readonly, nonatomic) BOOL isShowingTeamPatients;
@property (strong, nonatomic) WMPatient *patientToDelete;
@property (strong, nonatomic) WMPatient *patientToOpen;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIView *searchBarTextField;
@property (strong, nonatomic) IBOutlet UIView *patientReadOnlyContainerView;
@property (strong, nonatomic) IBOutlet UILabel *patientReadOnlyLabel;
@property (strong, nonatomic) NSAttributedString *patientReadOnlyText;
@property (readonly, nonatomic) WMPatientDetailViewController *patientDetailViewController;
@property (readonly, nonatomic) WMPatientSummaryContainerViewController *patientSummaryContainerViewController;
@property (readonly, nonatomic) WMPatientReferralViewController *patientReferralViewController;

- (IBAction)patientTypeValueChangedAction:(id)sender;

@end

@interface WMPatientTableViewController (PrivateMethods)
- (void)updateUIForPatientList;
- (void)deletePatient:(WMPatient *)patient;
@end

@implementation WMPatientTableViewController (PrivateMethods)

- (void)updateUIForPatientList
{
    if ([self.fetchedResultsController.fetchedObjects count] > 0 && !self.isSearchActive) {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)deletePatient:(WMPatient *)patient
{
    __weak __typeof(&*self)weakSelf = self;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        // select a patient
        weakSelf.patientToOpen = [WMPatient MR_findFirstOrderedByAttribute:WMPatientAttributes.createdAt ascending:NO inContext:managedObjectContext];
        if (nil == weakSelf.patientToOpen) {
            // need to create a patient
            [weakSelf.navigationController pushViewController:weakSelf.patientDetailViewController animated:YES];
        } else {
            [weakSelf updateUIForPatientList];
            [weakSelf.tableView reloadData];
        }
    };
    [self.appDelegate.navigationCoordinator deletePatient:patient completionHandler:^{
        onComplete(nil, nil, nil);
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
    [self.tableView registerClass:[WMPatientAutoTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.searchDisplayController.searchResultsTableView registerClass:[WMPatientAutoTableViewCell class] forCellReuseIdentifier:@"SearchCell"];
    _patientToOpen = self.patient;
    // show progress only if 24 hours has passed
    WMUserDefaultsManager *userDefaultsManager = [WMUserDefaultsManager sharedInstance];
    NSInteger hoursSinceLastPatientListUpdate = userDefaultsManager.hoursSinceLastPatientListUpdate;
    if (hoursSinceLastPatientListUpdate > 24) {
        [userDefaultsManager patientListUpdated];
        [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    }
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    [ffm fetchPatientsShallow:self.managedObjectContext ff:ff completionHandler:^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        [weakSelf.tableView reloadData];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
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

- (NSAttributedString *)patientReadOnlyText
{
    if (nil == _patientReadOnlyText) {
        NSURL *htmlString = [[NSBundle mainBundle]
                             URLForResource: @"PatientReadOnlyExplanation" withExtension:@"html"];
        _patientReadOnlyText = [[NSAttributedString alloc] initWithFileURL:htmlString
                                                                   options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                        documentAttributes:nil
                                                                     error:NULL];
    }
    return _patientReadOnlyText;
}

- (WMPatientDetailViewController *)patientDetailViewController
{
    WMPatientDetailViewController *patientDetailViewController = [[WMPatientDetailViewController alloc] initWithNibName:@"WMPatientDetailViewController" bundle:nil];
    patientDetailViewController.delegate = self;
    return patientDetailViewController;
}

- (WMPatientSummaryContainerViewController *)patientSummaryContainerViewController
{
    WMPatientSummaryContainerViewController *patientSummaryContainerViewController = [[WMPatientSummaryContainerViewController alloc] initWithNibName:@"WMPatientSummaryContainerViewController" bundle:nil];
    patientSummaryContainerViewController.delegate = self;
    return patientSummaryContainerViewController;
}

- (WMPatientReferralViewController *)patientReferralViewController
{
    WMPatientReferralViewController *patientReferralViewController = [[WMPatientReferralViewController alloc] initWithNibName:@"WMPatientReferralViewController" bundle:nil];
    patientReferralViewController.delegate = self;
    return patientReferralViewController;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    if (nil == _patientToOpen && self.fetchedResultsController.fetchedObjects.count > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Action Required"
                                                            message:@"Please select a patient"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else
    if ([self.appDelegate.navigationCoordinator canEditPatientOnDevice:_patientToOpen]) {
        [self.delegate patientTableViewController:self didSelectPatient:_patientToOpen];
    } else {
        _patientReadOnlyContainerView.frame = self.navigationController.view.bounds;
        _patientReadOnlyLabel.attributedText = self.patientReadOnlyText;
        [self.navigationController.view addSubview:_patientReadOnlyContainerView];
    }
}

// WMPatientConsultant is fetched from server, but properties are not populated
- (IBAction)patientTypeValueChangedAction:(id)sender
{
    [self refetchDataForTableView];
}

- (IBAction)continueReadonlyPatientAction:(id)sender
{
    [_patientReadOnlyContainerView removeFromSuperview];
    self.appDelegate.navigationCoordinator.patient = _patientToOpen;
    // get data from back end
    [MBProgressHUD showHUDAddedToViewController:self animated:YES].labelText = @"Loading Patient Data...";
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [_patientToOpen managedObjectContext];
    __weak __typeof(&*self)weakSelf = self;
    NSString *queryString = [NSString stringWithFormat:@"%@?depthGb=2&depthRef=2", _patientToOpen.ffUrl];
    [ff getObjFromUrl:queryString onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        [weakSelf.navigationController pushViewController:weakSelf.patientSummaryContainerViewController animated:YES];
    }];
}

- (IBAction)dismissReadonlyPatientViewAction:(id)sender
{
    [_patientReadOnlyContainerView removeFromSuperview];
}

- (IBAction)navigateToPatientReferral:(WMPatient *)patient
{
    self.appDelegate.navigationCoordinator.patient = patient;
    WMPatientReferral *patientReferral = [patient patientReferralForReferree:self.appDelegate.participant];
    WMPatientReferralViewController *patientReferralViewController = self.patientReferralViewController;
    patientReferralViewController.patientReferral = patientReferral;
    [self.navigationController pushViewController:patientReferralViewController animated:YES];
}

- (IBAction)unarchivePatient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    patient.archivedFlagValue = NO;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
    };
    [ff updateObj:patient onComplete:onComplete onOffline:onComplete];
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

#pragma mark - PatientDetailViewControllerDelegate

- (void)patientDetailViewControllerDidUpdatePatient:(WMPatientDetailViewController *)viewController
{
    _patientToOpen = viewController.patient;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)patientDetailViewControllerDidCancelUpdate:(WMPatientDetailViewController *)viewController
{
    // should not happen
}

#pragma mark - PatientSummaryContainerDelegate

- (void)patientSummaryContainerViewControllerDidFinish:(WMPatientSummaryContainerViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PatientReferralDelegate

- (void)patientReferralViewControllerDidFinish:(WMPatientReferralViewController *)viewController
{
    WMPatientReferral *patientReferral = viewController.patientReferral;
    [self.navigationController popViewControllerAnimated:YES];
    // patientReferral may have been deleted
    if (nil == patientReferral) {
        [self.tableView reloadData];
    } else {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:patientReferral.patient];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    // RPN push notification
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    ffm.postSynchronizationEvents = YES;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (void)patientReferralViewControllerDidCancel:(WMPatientReferralViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSManagedObjectContext *managedObjectContext = [_patientToDelete managedObjectContext];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
    };
    if (actionSheet.tag == kDeletePatientConfirmAlertTag) {
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            [self deletePatient:_patientToDelete];
        } else {
            NSInteger firstOtherButtonIndex = actionSheet.firstOtherButtonIndex;
            NSInteger otherButtonIndex = buttonIndex - firstOtherButtonIndex;
            switch (otherButtonIndex) {
                case 0: {
                    // Archive Patient
                    _patientToDelete.archivedFlagValue = YES;
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    [ff updateObj:_patientToDelete onComplete:onComplete onOffline:onComplete];
                    break;
                }
                case 1: {
                    // Archive & Delete Photos
                    _patientToDelete.archivedFlagValue = YES;
                    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
                    [ffm deletePhotosForPatient:_patientToDelete];
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    [ff updateObj:_patientToDelete onComplete:onComplete onOffline:onComplete];
                    break;
                }
            }
        }
        _patientToDelete = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self setEditing:NO];
    self.navigationItem.leftBarButtonItem = nil;
    if (self.navigationItem.rightBarButtonItem.target == self) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    self.navigationItem.hidesBackButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    [self performSelector:@selector(refetchDataForCoreTableView) withObject:nil afterDelay:0.25];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [self refetchDataForCoreTableView];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    [self refetchDataForCoreTableView];
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
                                                        otherButtonTitles:@"Archive Patient", @"Archive & Delete Photos", nil];
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
    WMPatientAutoTableViewCell *myCell = (WMPatientAutoTableViewCell *)cell;
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.isShowingTeamPatients) {
        WMParticipant *participant = self.appDelegate.participant;
        WMPatientReferral *patientReferral = [patient patientReferralForReferree:participant];
        __weak __typeof(&*self)weakSelf = self;
        [myCell updateForPatient:object patientReferral:patientReferral referralCallback:^(WMPatientAutoTableViewCell *myCell) {
            if (myCell == cell) {
                [weakSelf navigateToPatientReferral:patient];
            }
        } unarchiveCallback:^(WMPatientAutoTableViewCell *myCell) {
            if (myCell == cell) {
                [weakSelf unarchivePatient:patient];
            }
        }];
    } else {
        [myCell updateForPatientConsultant:object];
    }
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    return @[[NSString stringWithFormat:@"/%@", self.fetchedResultsControllerEntityName]];
}

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
        } else {
            predicate = [NSPredicate predicateWithFormat:@"%K == NO", WMPatientAttributes.archivedFlag];
        }
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
}

@end

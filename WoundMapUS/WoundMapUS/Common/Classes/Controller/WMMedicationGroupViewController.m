//
//  WMMedicationGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMMedicationGroupViewController.h"
#import "WMMedicationSummaryViewController.h"
#import "WMMedicationGroupHistoryViewController.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMMedicationCategory.h"
#import "WMMedication.h"
#import "WMMedicationGroup.h"
#import "WMInterventionEvent.h"
#import "WMInterventionEventType.h"
#import "WMInterventionStatus.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "IAPProduct.h"
#import "IAPManager.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

@interface WMMedicationGroupViewController ()

@property (strong, nonatomic) WMMedicationGroup *medicationGroup;

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (readonly, nonatomic) WMMedicationSummaryViewController *medicationSummaryViewController;
@property (readonly, nonatomic) WMMedicationGroupHistoryViewController *medicationGroupHistoryViewController;
@property (nonatomic) BOOL didCancel;

- (void)grabBagRemoveMedications:(NSArray *)medications;

@end

@implementation WMMedicationGroupViewController

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 860.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Medications";
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    _medicationGroup = [WMMedicationGroup activeMedicationGroup:patient];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    if (nil == _medicationGroup) {
        _medicationGroup = [WMMedicationGroup medicationGroupForPatient:patient];
        self.didCreateGroup = YES;
        WMInterventionEvent *event = [_medicationGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                               title:nil
                                                                           valueFrom:nil
                                                                             valueTo:nil
                                                                                type:[WMInterventionEventType interventionEventTypeForTitle:kInterventionEventTypePlan
                                                                                                                                     create:YES
                                                                                                                       managedObjectContext:managedObjectContext]
                                                                         participant:self.appDelegate.participant
                                                                              create:YES
                                                                managedObjectContext:managedObjectContext];
        DLog(@"Created event %@", event.eventType.title);
        // update backend
        FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [ff grabBagAddItemAtFfUrl:_medicationGroup.ffUrl
                         toObjAtFfUrl:patient.ffUrl
                          grabBagName:WMPatientRelationships.medicationGroups
                           onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                               if (error) {
                                   [WMUtilities logError:error];
                               }
                           }];
        };
        [ff createObj:_medicationGroup
                atUri:[NSString stringWithFormat:@"/%@", [WMMedicationGroup entityName]]
           onComplete:block
            onOffline:block];
    } else {
        dispatch_block_t block = ^{
            // we want to support cancel, so make sure we have an undoManager
            if (nil == managedObjectContext.undoManager) {
                managedObjectContext.undoManager = [[NSUndoManager alloc] init];
                _removeUndoManagerWhenDone = YES;
            }
            [managedObjectContext.undoManager beginUndoGrouping];
        };
        // values may not have been aquired from back end
        [ffm updateGrabBags:@[WMMedicationGroupRelationships.medications] aggregator:_medicationGroup ff:ff completionHandler:^(NSError *error) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf.tableView reloadData];
            block();
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Medication records.", (long)self.recentlyClosedCount]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        self.recentlyClosedCount = 0;
    }
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearDataCache
{
    [super clearDataCache];
    _medicationGroup = nil;
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return YES;
}

- (void)updateToolbarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:8];
    if ([WMMedicationGroup medicalGroupsHaveHistory:self.patient]) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showMedicationGroupHistoryAction:)]];
    }
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    NSString *title = (self.medicationGroup.status.isActive ? [NSString stringWithFormat:@"Current Status: %@", self.medicationGroup.status.title]:self.medicationGroup.status.title);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(updateStatusMedicationGroupAction:)];
    barButtonItem.enabled = self.medicationGroup.status.isActive;
    [items addObject:barButtonItem];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    if (self.medicationGroup.hasInterventionEvents) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showMedicationGroupEventsAction:)]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    self.title = @"Medications";
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    id value = nil;
    // refetch from database
    NSArray *medications = self.medicationGroup.medicationsInGroup;
    if ([medications containsObject:assessmentGroup]) {
        value = assessmentGroup;
    }
    return value;
}

#pragma mark - Core

- (WMMedicationSummaryViewController *)medicationSummaryViewController
{
    return [[WMMedicationSummaryViewController alloc] initWithNibName:@"WMMedicationSummaryViewController" bundle:nil];
}

- (WMMedicationGroupHistoryViewController *)medicationGroupHistoryViewController
{
    return [[WMMedicationGroupHistoryViewController alloc] initWithNibName:@"WMMedicationGroupHistoryViewController" bundle:nil];
}

- (void)grabBagRemoveMedications:(NSArray *)medications
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    for (WMMedication *medication in medications) {
        [ff grabBagRemoveItemAtFfUrl:medication.ffUrl
                      fromObjAtFfUrl:_medicationGroup.ffUrl
                         grabBagName:WMMedicationGroupRelationships.medications
                          onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                              if (error) {
                                  [WMUtilities logError:error];
                              }
                          }];
    }
}

#pragma mark - Actions

// show table of previous medicine assessments
- (IBAction)showMedicationGroupHistoryAction:(id)sender
{
    [self.navigationController pushViewController:self.medicationGroupHistoryViewController animated:YES];
}

- (IBAction)showMedicationGroupEventsAction:(id)sender
{
    [self presentInterventionEventViewController];
}

- (IBAction)updateStatusMedicationGroupAction:(id)sender
{
    [self presentInterventionStatusViewController];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    BOOL hasValues = [_medicationGroup.medications count] > 0;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
        if (managedObjectContext.undoManager.canUndo) {
            [managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            managedObjectContext.undoManager = nil;
        }
    }
    if (self.didCreateGroup || !hasValues) {
        [self.managedObjectContext deleteObject:_medicationGroup];
        // update backend
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        [ff grabBagRemove:_medicationGroup from:self.patient grabBagName:WMPatientRelationships.medicationGroups error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_medicationGroup error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    [self.delegate medicationGroupViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    BOOL hasValues = [_medicationGroup.medications count] > 0;
    if (!hasValues) {
        [self cancelAction:sender];
        return;
    }
    // else
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
        if (_removeUndoManagerWhenDone) {
            managedObjectContext.undoManager = nil;
        }
    }
    [super saveAction:sender];
    WMParticipant *participant = self.appDelegate.participant;
    // create intervention events before super
    [_medicationGroup createEditEventsForParticipant:participant];
    // update backend
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        WM_ASSERT_MAIN_THREAD;
        ffm.postSynchronizationEvents = YES;
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.delegate medicationGroupViewControllerDidSave:weakSelf];
    };
    // update back end
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            block();
        }
    };
    FFHttpMethodCompletion createOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        WMInterventionEvent *interventionEvent = (WMInterventionEvent *)object;
        [ff queueGrabBagAddItemAtUri:interventionEvent.ffUrl toObjAtUri:participant.ffUrl grabBagName:WMParticipantRelationships.interventionEvents];
        [ff queueGrabBagAddItemAtUri:interventionEvent.ffUrl toObjAtUri:_medicationGroup.ffUrl grabBagName:WMMedicationGroupRelationships.interventionEvents];
        completionHandler(error, object, response);
    };
    for (WMInterventionEvent *interventionEvent in participant.interventionEvents) {
        if (interventionEvent.ffUrl) {
            continue;
        }
        // else
        ++counter;
        [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@", [WMInterventionEvent entityName]] onComplete:createOnComplete onOffline:createOnComplete];
    }
    for (WMMedication *value in _medicationGroup.medications) {
        ++counter;
        [ff grabBagAddItemAtFfUrl:value.ffUrl toObjAtFfUrl:_medicationGroup.ffUrl grabBagName:WMMedicationGroupRelationships.medications onComplete:completionHandler];
    }
    ++counter;
    [ff updateObj:_medicationGroup onComplete:completionHandler];
}

#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"Medication Summary";
}

- (UIViewController *)summaryViewController
{
    WMMedicationSummaryViewController *medicationSummaryViewController = self.medicationSummaryViewController;
    medicationSummaryViewController.medicationGroup = self.medicationGroup;
    return medicationSummaryViewController;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return self.medicationGroup.status;
}

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.medicationGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.medicationGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                title:nil
                                                                            valueFrom:nil
                                                                              valueTo:nil
                                                                                 type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                              managedObjectContext:self.managedObjectContext]
                                                                          participant:self.appDelegate.participant
                                                                               create:YES
                                                                 managedObjectContext:self.managedObjectContext];
    DLog(@"Created WMnterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.medicationGroup;
}

- (void)interventionEventViewControllerDidCancel:(WMInterventionEventViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchActive) {
        return indexPath;
    }
    // else
    return (self.medicationGroup.status.isActive ? indexPath:nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMMedication *medication = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // IAP: check if category requires IAP
    IAPManager *iapManager = [IAPManager sharedInstance];
    if (nil != medication.category.iapIdentifier) {
        // check if user has purchased IAP
        IAPProduct *iapProduct = [IAPProduct productForIdentifier:medication.category.iapIdentifier create:NO managedObjectContext:self.managedObjectContext];
        if (![iapManager isProductPurchased:iapProduct]) {
            // IAP: this is an example of requiring an IAP for a medication category - present IAP view controller with success and failure block
            
            return;
        }
    }
    BOOL refreshTableView = NO;
    if ([self.medicationGroup.medications containsObject:medication]) {
        [self.medicationGroup removeMedicationsObject:medication];
        [self grabBagRemoveMedications:@[medication]];
    } else {
        if (medication.exludesOtherValues) {
            NSArray *medications = [self.medicationGroup.medications allObjects];
            for (WMMedication *m in medications) {
                [self.medicationGroup removeMedicationsObject:m];
            }
            [self grabBagRemoveMedications:medications];
            refreshTableView = YES;
        } else {
            refreshTableView = [self.medicationGroup removeExcludesOtherValues];
        }
        [self.medicationGroup addMedicationsObject:medication];
    }
    if (self.didCreateGroup) {
        self.medicationGroup.status = [WMInterventionStatus interventionStatusForTitle:kInterventionStatusInProcess
                                                                                create:NO
                                                                  managedObjectContext:self.managedObjectContext];
    }
    if (refreshTableView) {
        [tableView reloadData];
    } else {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self updateUIForDataChange];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
	id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
	id sortRank = sectionInfo.name;
    return [[WMMedicationCategory medicationCategoryForSortRank:sortRank managedObjectContext:self.managedObjectContext] title];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [super configureCell:cell atIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    if (self.didCreateGroup) {
        return nil;
    }
    // else
    return @[[NSString stringWithFormat:@"%@/%@", self.medicationGroup.ffUrl, WMMedicationGroupRelationships.medications]];
}

- (id)aggregator
{
    return _medicationGroup;
}

- (NSArray *)backendSeedEntityNames
{
    return @[];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return (self.isSearchActive ? @"WMDefinition":@"WMMedication");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeMedications];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [WMMedication predicateForWoundType:self.wound.woundType];
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    NSArray *sortDescriptors = nil;
    if (self.isSearchActive) {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES]];
    } else {
        sortDescriptors = [NSArray arrayWithObjects:
                           [NSSortDescriptor sortDescriptorWithKey:@"category.sortRank" ascending:YES],
                           [NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES], nil];
    }
    return sortDescriptors;
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
	return @"category.sortRank";
}

@end

//
//  WMMedicationGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMMedicationGroupViewController.h"
#import "WMMedicationSummaryViewController.h"
#import "WMMedicationGroupHistoryViewController.h"
#import "WMPatient.h"
#import "WMMedicationCategory.h"
#import "WMMedication.h"
#import "WMMedicationGroup.h"
#import "WMMedicationInterventionEvent.h"
#import "WMInterventionEventType.h"
#import "WMInterventionStatus.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "IAPProduct.h"
#import "IAPManager.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

@interface WMMedicationGroupViewController ()

@property (strong, nonatomic) NSBlockOperation *insertMedicationGroupOperation;

@property (readonly, nonatomic) WMMedicationSummaryViewController *medicationSummaryViewController;
@property (readonly, nonatomic) WMMedicationGroupHistoryViewController *medicationGroupHistoryViewController;
@property (nonatomic) BOOL didCancel;

@end

@implementation WMMedicationGroupViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Medication records. A new Medication Plan has been created for you.", (long)self.recentlyClosedCount]
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
    _insertMedicationGroupOperation = nil;
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

- (void)updateUIForSearch
{
    [super updateUIForSearch];
    self.title = @"Search Definitions";
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

- (WMMedicationGroup *)medicationGroup
{
    if (nil == _medicationGroup) {
        WMMedicationGroup *medicationGroup = [WMMedicationGroup activeMedicationGroup:self.patient];
        if (nil == medicationGroup) {
            medicationGroup = [WMMedicationGroup medicationGroupForPatient:self.patient];
            self.didCreateGroup = YES;
            // update back end
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
            NSBlockOperation *insertMedicationGroupOperation = [ffm createObject:medicationGroup
                                                                           ffUrl:[WMMedicationGroup entityName]
                                                                              ff:ff
                                                                      addToQueue:NO
                                                               completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                                                                   NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                   [managedObjectContext MR_saveToPersistentStoreAndWait];
                                                               }];
            WMInterventionEvent *event = [medicationGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                   title:nil
                                                                               valueFrom:nil
                                                                                 valueTo:nil
                                                                                    type:[WMInterventionEventType interventionEventTypeForTitle:kInterventionEventTypePlan
                                                                                                                                         create:YES
                                                                                                                           managedObjectContext:self.managedObjectContext]
                                                                             participant:self.appDelegate.participant
                                                                                  create:YES
                                                                    managedObjectContext:self.managedObjectContext];
            NSManagedObjectID *medicationGroupObjectID = [_medicationGroup objectID];
            NSManagedObjectID *eventObjectID = [event objectID];
            NSBlockOperation *eventOperation = [ffm createObject:event
                                                           ffUrl:[WMInterventionEvent entityName]
                                                              ff:ff
                                                      addToQueue:NO
                                               completionHandler:^(NSError *error, id object, BOOL signInRequired) {
                                                   NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                                   WMMedicationGroup *medicationGroup = (WMMedicationGroup *)[managedObjectContext objectWithID:medicationGroupObjectID];
                                                   WMInterventionEvent *event = (WMInterventionEvent *)[managedObjectContext objectWithID:eventObjectID];
                                                   NSString *medicationGroupFFURL = medicationGroup.ffUrl;
                                                   NSString *eventFFURL = event.ffUrl;
                                                   NSAssert([medicationGroupFFURL length] > 0, @"WMMedicationGroup.ffUrl should not be nil");
                                                   NSAssert([eventFFURL length] > 0, @"WMInterventionEvent.ffUrl should not be nil");
                                                   [ff queueGrabBagAddItemAtUri:eventFFURL toObjAtUri:medicationGroupFFURL grabBagName:WMMedicationGroupRelationships.interventionEvents];
                                               }];
            [eventOperation addDependency:insertMedicationGroupOperation];
            DLog(@"Created event %@", event.eventType.title);
        }
        self.medicationGroup = medicationGroup;
    }
    return _medicationGroup;
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
    self.willCancelFlag = YES;
    BOOL hasValues = [_medicationGroup.medications count] > 0;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
        if (managedObjectContext.undoManager.canUndo) {
            [managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (self.didCreateGroup || !hasValues) {
        NSString *patientFFURL = self.patient.ffUrl;
        NSString *medicationGroupFFURL = _medicationGroup.ffUrl;
        [managedObjectContext deleteObject:_medicationGroup];
        [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                if ([medicationGroupFFURL length] > 0) {
                    WMFatFractal *ff = [WMFatFractal sharedInstance];
                    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
                    [ffm deleteObject:_medicationGroup ff:ff addToQueue:YES completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
                        [ff queueGrabBagRemoveItemAtUri:medicationGroupFFURL fromObjAtUri:patientFFURL grabBagName:WMPatientRelationships.medicationGroups];
                    }];
                }
            } else {
                [WMUtilities logError:error];
            }
        }];
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
    }
    [super saveAction:sender];
    // create intervention events before super
    NSArray *events = [_medicationGroup createEditEventsForParticipant:self.appDelegate.participant];
    NSArray *medicationsAdded = _medicationGroup.medicationsAdded;
    NSArray *medicationsRemoved = _medicationGroup.medicationsRemoved;
    // update back end - need to handle medications added/removed, interventionEvents added
    NSManagedObjectID *medicationGroupObjectID = [_medicationGroup objectID];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        NSBlockOperation *operation = [ffm createArray:[events valueForKey:@"objectID"] collection:[WMInterventionEvent entityName] ff:ff addToQueue:NO completionHandler:^(NSError *error, id object, BOOL signInRequired) {
            NSParameterAssert([object isKindOfClass:[NSManagedObjectID class]]);
            NSManagedObjectID *objectID = (NSManagedObjectID *)object;
            NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            WMMedicationGroup *medicationGroup = (WMMedicationGroup *)[managedObjectContext objectWithID:medicationGroupObjectID];
            WMInterventionEvent *event = (WMInterventionEvent *)[managedObjectContext objectWithID:objectID];
            NSString *medicationGroupFFURL = medicationGroup.ffUrl;
            NSString *eventFFURL = event.ffUrl;
            NSAssert([medicationGroupFFURL length] > 0, @"WMMedicationGroup.ffUrl should not be nil");
            NSAssert([eventFFURL length] > 0, @"WMInterventionEvent.ffUrl should not be nil");
            [ff queueGrabBagAddItemAtUri:eventFFURL toObjAtUri:medicationGroupFFURL grabBagName:WMMedicationGroupRelationships.interventionEvents];
        }];
        if (_insertMedicationGroupOperation) {
            [operation addDependency:_insertMedicationGroupOperation];
        }
        for (WMMedication *medication in medicationsAdded) {
            NSBlockOperation *operation = [ffm grabBagAdd:[medication objectID]
                                                       to:medicationGroupObjectID
                                              grabBagName:WMMedicationGroupRelationships.medications
                                                       ff:ff
                                               addToQueue:NO];
            if (_insertMedicationGroupOperation) {
                [operation addDependency:_insertMedicationGroupOperation];
            }
        }
        for (WMMedication *medication in medicationsRemoved) {
            NSBlockOperation *operation = [ffm grabBagRemove:[medication objectID]
                                                          to:medicationGroupObjectID
                                                 grabBagName:WMMedicationGroupRelationships.medications
                                                          ff:ff
                                                  addToQueue:NO];
            if (_insertMedicationGroupOperation) {
                [operation addDependency:_insertMedicationGroupOperation];
            }
        }
        // submit to back end
        [ffm submitOperationsToQueue];
    }];
    [self.delegate medicationGroupViewControllerDidSave:self];
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
    DLog(@"Created WMMedicationInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
    // update back end
    NSManagedObjectID *medicationGroupObjectID = [_medicationGroup objectID];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ffm createObject:event ffUrl:[WMInterventionEvent entityName] ff:ff addToQueue:NO completionHandler:^(NSError *error, id object, BOOL signInRequired) {
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMMedicationGroup *medicationGroup = (WMMedicationGroup *)[managedObjectContext objectWithID:medicationGroupObjectID];
        WMInterventionEvent *event = (WMInterventionEvent *)object;
        NSString *medicationGroupFFURL = medicationGroup.ffUrl;
        NSString *eventFFURL = event.ffUrl;
        NSAssert([medicationGroupFFURL length] > 0, @"WMMedicationGroup.ffUrl should not be nil");
        NSAssert([eventFFURL length] > 0, @"WMInterventionEvent.ffUrl should not be nil");
        [ff queueGrabBagAddItemAtUri:eventFFURL toObjAtUri:medicationGroupFFURL grabBagName:WMMedicationGroupRelationships.interventionEvents];
    }];
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
    } else {
        if (medication.exludesOtherValues) {
            NSArray *medications = [self.medicationGroup.medications allObjects];
            for (WMMedication *m in medications) {
                [self.medicationGroup removeMedicationsObject:m];
            }
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
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

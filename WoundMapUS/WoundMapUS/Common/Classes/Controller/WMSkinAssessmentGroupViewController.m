//
//  WMSkinAssessmentGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMSkinAssessmentGroupViewController.h"
#import "WMSkinAssessmentSummaryViewController.h"
#import "WMSkinAssessmentGroupHistoryViewController.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentCategory.h"
#import "WMSkinAssessment.h"
#import "WMSkinAssessmentValue.h"
#import "WMSkinAssessmentIntEvent.h"
#import "WMInterventionStatus.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"

@interface WMSkinAssessmentGroupViewController ()

@property (readonly, nonatomic) WMSkinAssessmentSummaryViewController *skinAssessmentSummaryViewController;
@property (readonly, nonatomic) WMSkinAssessmentGroupHistoryViewController *skinAssessmentGroupHistoryViewController;

@end

@implementation WMSkinAssessmentGroupViewController

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
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Skin Assessment records. A new Skin Assessment record has been created for you.", (long)self.recentlyClosedCount]
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
    _skinAssessmentGroup = nil;
    _navigationNode = nil;
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return YES;
}

- (void)updateToolbarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:8];
    if ([WMSkinAssessmentGroup skinAssessmentGroupsHaveHistory:self.patient]) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showSkinAssessmentGroupHistoryAction:)]];
    }
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    NSString *title = (self.skinAssessmentGroup.status.isActive ? [NSString stringWithFormat:@"Current Status: %@", self.skinAssessmentGroup.status.title]:self.skinAssessmentGroup.status.title);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(updateStatusSkinAssessmentGroupAction:)];
    barButtonItem.enabled = self.skinAssessmentGroup.status.isActive;
    [items addObject:barButtonItem];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    if (self.skinAssessmentGroup.hasInterventionEvents) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showSkinAssessmentGroupEventsAction:)]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    self.title = @"Skin Assessment";
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)updateUIForSearch
{
    [super updateUIForSearch];
    self.title = @"Search Definitions";
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMSkinAssessment *skinAssessment = (WMSkinAssessment *)assessmentGroup;
    WMSkinAssessmentValue *skinAssessmentValue = [self.skinAssessmentGroup skinAssessmentValueForSkinAssessment:skinAssessment
                                                                                                         create:NO
                                                                                                          value:nil
                                                                                           managedObjectContext:self.managedObjectContext];
    if (nil == skinAssessmentValue) {
        return nil;
    }
    // else
    if (skinAssessment.groupValueTypeCode == GroupValueTypeCodeSelect) {
        return skinAssessmentValue;
    }
    // else
    return skinAssessmentValue.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    WMSkinAssessment *skinAssessment = (WMSkinAssessment *)assessmentGroup;
    BOOL createSkinAssessmentValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createSkinAssessmentValue = [value length] > 0;
    }
    if (createSkinAssessmentValue) {
        // unselect any other selection in category (section)
        [self.skinAssessmentGroup removeSkinAssessmentValuesForCategory:skinAssessment.category];
    }
    WMSkinAssessmentValue *skinAssessmentValue = [self.skinAssessmentGroup skinAssessmentValueForSkinAssessment:skinAssessment
                                                                                                         create:createSkinAssessmentValue
                                                                                                          value:nil
                                                                                           managedObjectContext:self.managedObjectContext];
    if (createSkinAssessmentValue) {
        skinAssessmentValue.value = value;
    } else if (nil != skinAssessmentValue) {
        [self.skinAssessmentGroup removeValuesObject:skinAssessmentValue];
        [self.managedObjectContext deleteObject:skinAssessmentValue];
    }
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:skinAssessment];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Core

- (WMSkinAssessmentSummaryViewController *)skinAssessmentSummaryViewController
{
    return [[WMSkinAssessmentSummaryViewController alloc] initWithNibName:@"WMSkinAssessmentSummaryViewController" bundle:nil];
}

- (WMSkinAssessmentGroupHistoryViewController *)skinAssessmentGroupHistoryViewController
{
    return [[WMSkinAssessmentGroupHistoryViewController alloc] initWithNibName:@"WMSkinAssessmentGroupHistoryViewController" bundle:nil];
}

- (WMSkinAssessmentGroup *)skinAssessmentGroup
{
    if (nil == _skinAssessmentGroup) {
        WMSkinAssessmentGroup *skinAssessmentGroup = nil;
        if (nil == _skinAssessmentGroupObjectID) {
            skinAssessmentGroup = [WMSkinAssessmentGroup activeSkinAssessmentGroupWithNavigationNode:self.navigationNode];
            if (nil == skinAssessmentGroup) {
                // TODO: determine if we should revise an inactive group and replace the nil below if so
                skinAssessmentGroup = [WMSkinAssessmentGroup skinAssessmentGroupByRevising:nil managedObjectContext:self.managedObjectContext];
                self.didCreateGroup = YES;
                WMInterventionEvent *event = [skinAssessmentGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                           title:nil
                                                                                       valueFrom:nil
                                                                                         valueTo:nil
                                                                                            type:[WMInterventionEventType interventionEventTypeForTitle:kInterventionEventTypePlan
                                                                                                                                                 create:YES
                                                                                                                                   managedObjectContext:self.managedObjectContext
                                                                                                                                        persistentStore:nil]
                                                                                            user:[self.appDelegate signedInUserForDocument:self.document]
                                                                                          create:YES
                                                                            managedObjectContext:self.managedObjectContext
                                                                                 persistentStore:nil];
                DLog(@"Created event %@", event.eventType.title);
            }
        } else {
            skinAssessmentGroup = (WMSkinAssessmentGroup *)[self.managedObjectContext objectWithID:_skinAssessmentGroupObjectID];
        }
        self.skinAssessmentGroup = skinAssessmentGroup;
    }
    return _skinAssessmentGroup;
}

#pragma mark - Actions

- (IBAction)showSkinAssessmentGroupHistoryAction:(id)sender
{
    [self.navigationController pushViewController:self.skinAssessmentGroupHistoryViewController animated:YES];
}

- (IBAction)updateStatusSkinAssessmentGroupAction:(id)sender
{
    [self presentInterventionStatusViewController];
}

- (IBAction)showSkinAssessmentGroupEventsAction:(id)sender
{
    [self presentInterventionEventViewController];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.willCancelFlag && self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (self.didCreateGroup && [[self.skinAssessmentGroup objectID] isTemporaryID]) {
        [self.managedObjectContext deleteObject:self.skinAssessmentGroup];
        [self clearDataCache];
    }
    [self.delegate skinAssessmentGroupViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [super saveAction:sender];
    // create intervention events before super
    [self.skinAssessmentGroup createEditEventsForUser:[self.appDelegate signedInUserForDocument:self.document]];
    [self.delegate skinAssessmentGroupViewControllerDidSave:self];
}

#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"Assessment Summary";
}

- (UIViewController *)summaryViewController
{
    WMSkinAssessmentSummaryViewController *skinAssessmentSummaryViewController = self.skinAssessmentSummaryViewController;
    skinAssessmentSummaryViewController.skinAssessmentGroup = self.skinAssessmentGroup;
    return skinAssessmentSummaryViewController;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return self.skinAssessmentGroup.status;
}

- (void)interventionStatusViewController:(InterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.skinAssessmentGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.skinAssessmentGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                    title:nil
                                                                                valueFrom:nil
                                                                                  valueTo:nil
                                                                                     type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                                  managedObjectContext:self.managedObjectContext
                                                                                                                                       persistentStore:nil]
                                                                                     user:[self.appDelegate signedInUserForDocument:self.document]
                                                                                   create:YES
                                                                     managedObjectContext:self.managedObjectContext
                                                                          persistentStore:nil];
    DLog(@"Created WMSkinAssessmentInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.skinAssessmentGroup;
}

- (void)interventionEventViewControllerDidCancel:(InterventionEventViewController *)viewController
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
    return (self.skinAssessmentGroup.status.isActive ? indexPath:nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMSkinAssessment *skinAssessment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMSkinAssessmentValue *skinAssessmentValue = [self.skinAssessmentGroup skinAssessmentValueForSkinAssessment:skinAssessment
                                                                                                         create:NO
                                                                                                          value:nil
                                                                                           managedObjectContext:self.managedObjectContext];
    BOOL reloadSection = YES;
    if (nil == skinAssessmentValue) {
        // no skinAssessmentValue for this skinAssessment - add one or make control first responder
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIResponder *responder = [self possibleFirstResponderInCell:cell];
        if (nil == responder) {
            // unselect any other selection in category (section)
            [self.skinAssessmentGroup removeSkinAssessmentValuesForCategory:skinAssessment.category];
            // go ahead and select
            [self.skinAssessmentGroup skinAssessmentValueForSkinAssessment:skinAssessment
                                                                    create:YES
                                                                     value:nil
                                                      managedObjectContext:self.managedObjectContext];
        } else {
            self.indexPathForDelayedFirstResponder = indexPath;
            [responder performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
            reloadSection = NO;
        }
    } else {
        // unselect - remove
        [self.skinAssessmentGroup removeValuesObject:skinAssessmentValue];
        [self.managedObjectContext deleteObject:skinAssessmentValue];
    }
    // reload section
    if (reloadSection) {
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    // update remaining UI
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
    return [[WMSkinAssessmentCategory skinAssessmentCategoryForSortRank:sortRank
                                                   managedObjectContext:self.managedObjectContext
                                                        persistentStore:nil] title];
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMSkinAssessment");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeSkinAssessment];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [WMSkinAssessment predicateForWoundType:self.wound.woundType];
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

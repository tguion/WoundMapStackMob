//
//  WMDevicesViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMDevicesViewController.h"
#import "WMDevicesGroupHistoryViewContoller.h"
#import "WMDevicesSummaryViewController.h"
#import "WMDeviceCategory.h"
#import "WMDevice.h"
#import "WMDeviceGroup.h"
#import "WMDeviceValue.h"
#import "WMDeviceInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "UIView+Custom.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"

@interface WMDevicesViewController ()

@property (readonly, nonatomic) WMDevicesGroupHistoryViewContoller *devicesGroupHistoryViewContoller;
@property (readonly, nonatomic) WMDevicesSummaryViewController *devicesSummaryViewController;

@end

@implementation WMDevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Devices";
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Device records. A new Device Record has been created for you.", (long)self.recentlyClosedCount]
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
    _deviceGroup = nil;
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return YES;
}

- (void)updateToolbarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:8];
    if ([WMDeviceGroup deviceGroupsHaveHistory:self.patient]) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showDeviceGroupHistoryAction:)]];
    }
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    NSString *title = (self.deviceGroup.status.isActive ? [NSString stringWithFormat:@"Current Status: %@", self.deviceGroup.status.title]:self.deviceGroup.status.title);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(updateStatusDeviceGroupAction:)];
    barButtonItem.enabled = self.deviceGroup.status.isActive;
    [items addObject:barButtonItem];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    if (self.deviceGroup.hasInterventionEvents) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showDeviceGroupEventsAction:)]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    self.title = @"Devices";
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)updateUIForSearch
{
    [super updateUIForSearch];
    self.title = @"Search Definitions";
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMDevice *device = (WMDevice *)assessmentGroup;
    WMDeviceValue *deviceValue = [self.deviceGroup deviceValueForDevice:device
                                                                 create:NO
                                                                  value:nil
                                                   managedObjectContext:self.managedObjectContext];
    if (nil == deviceValue) {
        return nil;
    }
    // else
    if (device.groupValueTypeCode == GroupValueTypeCodeSelect) {
        return deviceValue;
    }
    // else
    return deviceValue.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    BOOL createDeviceValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createDeviceValue = [value length] > 0;
    }
    WMDeviceValue *deviceValue = [self.deviceGroup deviceValueForDevice:assessmentGroup
                                                                 create:createDeviceValue
                                                                  value:nil
                                                   managedObjectContext:self.managedObjectContext];
    if (createDeviceValue) {
        deviceValue.value = value;
        [self.deviceGroup addValuesObject:deviceValue];
    } else if (nil != deviceValue) {
        [self.deviceGroup removeValuesObject:deviceValue];
        [self.managedObjectContext deleteObject:deviceValue];
    }
}

#pragma mark - Core

- (WMDeviceGroup *)deviceGroup
{
    if (nil == _deviceGroup) {
        WMDeviceGroup *deviceGroup = nil;
        if (nil == _deviceGroupObjectID) {
            deviceGroup = [WMDeviceGroup deviceGroupByRevising:nil managedObjectContext:self.managedObjectContext];
            self.didCreateGroup = YES;
            WMInterventionEvent *event = [deviceGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
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
        } else {
            deviceGroup = (WMDeviceGroup *)[self.managedObjectContext objectWithID:_deviceGroupObjectID];
        }
        self.deviceGroup = deviceGroup;
    }
    return _deviceGroup;
}

- (WMDevicesGroupHistoryViewContoller *)devicesGroupHistoryViewContoller
{
    return [[WMDevicesGroupHistoryViewContoller alloc] initWithNibName:@"WMDevicesGroupHistoryViewContoller" bundle:nil];
}

- (WMDevicesSummaryViewController *)devicesSummaryViewController
{
    return [[WMDevicesSummaryViewController alloc] initWithNibName:@"WMDevicesSummaryViewController" bundle:nil];
}

#pragma mark - BaseViewController

#pragma mark - iCloud

// called when self.document content changes
- (void)handleDocumentContentsUpdated:(UIManagedDocument *)document
{
    // refresh relationships for fetched data
    [DocumentManager faultObjectWithID:[self.deviceGroup objectID] inContext:self.managedObjectContext];
    [super handleDocumentContentsUpdated:document];
}

#pragma mark - Actions

// show table of previous medicine assessments
- (IBAction)showDeviceGroupHistoryAction:(id)sender
{
    [self.navigationController pushViewController:self.devicesGroupHistoryViewContoller animated:YES];
}

- (IBAction)showDeviceGroupEventsAction:(id)sender
{
    [self presentInterventionEventViewController];
}

- (IBAction)updateStatusDeviceGroupAction:(id)sender
{
    [self presentInterventionStatusViewController];
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
    if (self.didCreateGroup) {
        [self.managedObjectContext deleteObject:self.deviceGroup];
    }
    [self.documentManager saveDocument:self.document];
    [self.delegate devicesViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [super saveAction:sender];
    // create intervention events before super
    [self.deviceGroup createEditEventsForUser:[self.appDelegate signedInUserForDocument:self.document]];
    [self.delegate devicesViewControllerDidSave:self];
}

#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"Device Summary";
}

- (UIViewController *)summaryViewController
{
    WMDevicesSummaryViewController *devicesSummaryViewController = self.devicesSummaryViewController;
    devicesSummaryViewController.devicesGroup = self.deviceGroup;
    return devicesSummaryViewController;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return self.deviceGroup.status;
}

- (void)interventionStatusViewController:(InterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.deviceGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.deviceGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
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
    DLog(@"Created WMDeviceInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.deviceGroup;
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
    return (self.deviceGroup.status.isActive ? indexPath:nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (nil != self.indexPathForDelayedFirstResponder && ![indexPath isEqual:self.indexPathForDelayedFirstResponder]) {
        self.indexPathForDelayedFirstResponder = nil;
    }
    BOOL refreshRow = YES;
    // check if there is a control in the cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIResponder *responder = [self possibleFirstResponderInCell:cell];
    if (nil == responder) {
        [[self.view findFirstResponder] resignFirstResponder];
        // check for a control
        UIControl *control = [self controlInCell:cell];
        if (nil != control) {
            // no need to refresh any rows
            refreshRow = NO;
        }
    } else {
        // just allow first responder to respond
        self.indexPathForDelayedFirstResponder = indexPath;
        [responder performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
        refreshRow = NO;
    }
    // if not control, add or remove value
    if (refreshRow) {
        BOOL refreshTableView = NO;
        WMDevice *device = [self.fetchedResultsController objectAtIndexPath:indexPath];
        WMDeviceValue *deviceValue = [self.deviceGroup deviceValueForDevice:device
                                                                     create:NO
                                                                      value:nil
                                                       managedObjectContext:self.managedObjectContext];
        if (nil == deviceValue) {
            // check if this is a none type exludesOtherValues
            if (device.exludesOtherValues) {
                refreshTableView = YES;
                NSArray *values = [self.deviceGroup.values allObjects];
                for (WMDeviceValue *value in values) {
                    [self.deviceGroup removeValuesObject:value];
                    [self.managedObjectContext deleteObject:value];
                }
            } else {
                refreshTableView = [self.deviceGroup removeExcludesOtherValues];
            }
            // else go ahead and select
            deviceValue = [self.deviceGroup deviceValueForDevice:device
                                                          create:YES
                                                           value:nil
                                            managedObjectContext:self.managedObjectContext];
            [self.deviceGroup addValuesObject:deviceValue];
        } else {
            // unselect - remove
            [self.deviceGroup removeValuesObject:deviceValue];
            [self.managedObjectContext deleteObject:deviceValue];
        }
        // allow multiple selection
        if (refreshTableView) {
            [tableView reloadData];
        } else {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
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
    return [[WMDeviceCategory deviceCategoryForSortRank:sortRank managedObjectContext:self.managedObjectContext persistentStore:nil] title];
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMDevice");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundDevice];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [WMDevice predicateForWoundType:self.wound.woundType];
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

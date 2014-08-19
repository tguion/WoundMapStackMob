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
#import "WMNoteViewController.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMDeviceCategory.h"
#import "WMDevice.h"
#import "WMDeviceGroup.h"
#import "WMDeviceValue.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMFatFractal.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMDevicesViewController () <NoteViewControllerDelegate>

@property (strong, nonatomic) WMDeviceGroup *deviceGroup;
@property (strong, nonatomic) WMDevice *selectedDevice;

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (readonly, nonatomic) WMDevicesGroupHistoryViewContoller *devicesGroupHistoryViewContoller;
@property (readonly, nonatomic) WMDevicesSummaryViewController *devicesSummaryViewController;
@property (readonly, nonatomic) WMNoteViewController *noteViewController;

@end

@implementation WMDevicesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 880.0);
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
            [weakSelf.tableView reloadData];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Devices";
    WMPatient *patient = self.patient;
    _deviceGroup = [WMDeviceGroup activeDeviceGroup:patient];
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    if (_deviceGroup) {
        dispatch_block_t block = ^{
            // we want to support cancel, so make sure we have an undoManager
            if (nil == managedObjectContext.undoManager) {
                managedObjectContext.undoManager = [[NSUndoManager alloc] init];
                _removeUndoManagerWhenDone = YES;
            }
            [managedObjectContext.undoManager beginUndoGrouping];
        };
        // values may not have been aquired from back end
        if ([_deviceGroup.values count] == 0) {
            [ffm updateGrabBags:@[WMDeviceGroupRelationships.values] aggregator:_deviceGroup ff:ff completionHandler:^(NSError *error) {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                block();
            }];
        } else {
            block();
        }
    } else {
        _deviceGroup = [WMDeviceGroup deviceGroupForPatient:patient];
        self.didCreateGroup = YES;
        WMInterventionEvent *event = [_deviceGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
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
        __weak __typeof(&*self)weakSelf = self;
        FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [ff queueGrabBagAddItemAtUri:_deviceGroup.ffUrl toObjAtUri:weakSelf.patient.ffUrl grabBagName:WMPatientRelationships.deviceGroups];
        };
        [ff createObj:_deviceGroup
                atUri:[NSString stringWithFormat:@"/%@", [WMDeviceGroup entityName]]
           onComplete:block
            onOffline:block];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Device records.", (long)self.recentlyClosedCount]
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

#pragma mark - Notification handlers

- (void)handleDefaultManagedObjectContextWillSave:(NSNotification *)notification
{
    
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
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad"]
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
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets"]
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

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMDevice *device = (WMDevice *)assessmentGroup;
    WMDeviceValue *deviceValue = [self.deviceGroup deviceValueForDevice:device
                                                                 create:NO
                                                                  value:nil];
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
                                                                  value:nil];
    if (createDeviceValue) {
        deviceValue.value = value;
        [self.deviceGroup addValuesObject:deviceValue];
    } else if (nil != deviceValue) {
        [self.deviceGroup removeValuesObject:deviceValue];
        [self deleteDeviceValuesFromBackEnd:@[deviceValue]];
        [self.managedObjectContext deleteObject:deviceValue];
    }
}

#pragma mark - Core

- (void)navigateToNoteViewController:(WMDevice *)device
{
    self.selectedDevice = device;
    [self.navigationController pushViewController:self.noteViewController animated:YES];
}

- (WMNoteViewController *)noteViewController
{
    WMNoteViewController *noteViewController = [[WMNoteViewController alloc] initWithNibName:@"WMNoteViewController" bundle:nil];
    noteViewController.delegate = self;
    return noteViewController;
}

- (void)deleteDeviceValuesFromBackEnd:(NSArray *)deviceValues
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    for (WMDeviceValue *deviceValue in deviceValues) {
        if (deviceValue.ffUrl) {
            [ff deleteObj:deviceValue
               onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                   if (error) {
                       [WMUtilities logError:error];
                   }
               } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                   if (error) {
                       [WMUtilities logError:error];
                   }
               }];
        }
    }
}

- (WMDevicesGroupHistoryViewContoller *)devicesGroupHistoryViewContoller
{
    return [[WMDevicesGroupHistoryViewContoller alloc] initWithNibName:@"WMDevicesGroupHistoryViewContoller" bundle:nil];
}

- (WMDevicesSummaryViewController *)devicesSummaryViewController
{
    return [[WMDevicesSummaryViewController alloc] initWithNibName:@"WMDevicesSummaryViewController" bundle:nil];
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
    BOOL hasValues = [_deviceGroup.devices count] > 0;
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.willCancelFlag && self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    if (self.didCreateGroup || !hasValues) {
        [self.managedObjectContext deleteObject:_deviceGroup];
        // update backend
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        [ff grabBagRemove:_deviceGroup from:self.patient grabBagName:WMPatientRelationships.deviceGroups error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_deviceGroup error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    [self.delegate devicesViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    if ([_deviceGroup.values count] == 0) {
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
    // create intervention events before super
    [_deviceGroup createEditEventsForParticipant:self.appDelegate.participant];
    // update backend
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block NSInteger counter = 1;  // update _deviceGroup
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        WM_ASSERT_MAIN_THREAD;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        [weakSelf.delegate devicesViewControllerDidSave:weakSelf];
    };
    // update back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            block();
        }
    };
    WMParticipant *participant = self.appDelegate.participant;
    FFHttpMethodCompletion onCreateComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        WMInterventionEvent *interventionEvent = nil;
        if ([object isKindOfClass:[WMInterventionEvent class]]) {
            interventionEvent = (WMInterventionEvent *)object;
        } else {
            FFQueuedOperation *q = (FFQueuedOperation *)object;
            interventionEvent = (WMInterventionEvent *)q.queuedObj;
        }
        [ff queueGrabBagAddItemAtUri:interventionEvent.ffUrl toObjAtUri:participant.ffUrl grabBagName:WMParticipantRelationships.interventionEvents];
        [ff queueGrabBagAddItemAtUri:interventionEvent.ffUrl toObjAtUri:_deviceGroup.ffUrl grabBagName:WMDeviceGroupRelationships.interventionEvents];
    };
    NSSet *updatedObjects = managedObjectContext.updatedObjects;
    for (WMInterventionEvent *interventionEvent in participant.interventionEvents) {
        if (interventionEvent.ffUrl) {
            if ([updatedObjects containsObject:interventionEvent]) {
                ++counter;
                [ff updateObj:interventionEvent
                   onComplete:completionHandler
                    onOffline:completionHandler];
            }
            continue;
        }
        // else
        [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@", [WMInterventionEvent entityName]] onComplete:onCreateComplete onOffline:onCreateComplete];
    }
    for (WMDeviceValue *value in _deviceGroup.values) {
        if (value.ffUrl) {
            if ([updatedObjects containsObject:value]) {
                ++counter;
                [ff updateObj:value
                   onComplete:completionHandler
                    onOffline:completionHandler];
            }
            continue;
        }
        // else
        ++counter;
        [ff createObj:value atUri:[NSString stringWithFormat:@"/%@", [WMDeviceValue entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:_deviceGroup.ffUrl grabBagName:WMDeviceGroupRelationships.values];
            completionHandler(error, object, response);
        }];
    }
    [ff updateObj:_deviceGroup onComplete:completionHandler onOffline:completionHandler];
}

#pragma mark - NoteViewControllerDelegate

- (NSString *)note
{
    WMDeviceValue *value = [_deviceGroup deviceValueForDevice:_selectedDevice create:NO value:nil];
    return value.value;
}

- (NSString *)label
{
    return _selectedDevice.title;
}

- (void)noteViewController:(WMNoteViewController *)viewController didUpdateNote:(NSString *)note
{
    WMDeviceValue *value = [_deviceGroup deviceValueForDevice:_selectedDevice create:NO value:nil];
    value.value = note;
    [self.navigationController popViewControllerAnimated:YES];
    // reload the section if only one selection allowed
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:_selectedDevice];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    _selectedDevice = nil;
}

- (void)noteViewControllerDidCancel:(WMNoteViewController *)viewController withNote:(NSString *)note
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.deviceGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.deviceGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                            title:nil
                                                                        valueFrom:nil
                                                                          valueTo:nil
                                                                             type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                          managedObjectContext:self.managedObjectContext]
                                                                      participant:self.appDelegate.participant
                                                                           create:YES
                                                             managedObjectContext:self.managedObjectContext];
    DLog(@"Created WMInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.deviceGroup;
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
    WMDevice *device = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (device.groupValueTypeCode == GroupValueTypeCodeNavigateToNote) {
        [self navigateToNoteViewController:device];
        return;
    }
    // else
    if (nil != self.indexPathForDelayedFirstResponder && ![indexPath isEqual:self.indexPathForDelayedFirstResponder]) {
        self.indexPathForDelayedFirstResponder = nil;
    }
    BOOL refreshRow = YES;
    // check if there is a control in the cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIResponder *responder = [self possibleFirstResponderInCell:cell];
    if (nil == responder) {
        [self.view endEditing:YES];
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
        WMDeviceValue *deviceValue = [self.deviceGroup deviceValueForDevice:device
                                                                     create:NO
                                                                      value:nil];
        if (nil == deviceValue) {
            // check if this is a none type exludesOtherValues
            if (device.exludesOtherValues) {
                refreshTableView = YES;
                NSArray *values = [self.deviceGroup.values allObjects];
                for (WMDeviceValue *value in values) {
                    [self.deviceGroup removeValuesObject:value];
                    [self.managedObjectContext deleteObject:value];
                }
                [self deleteDeviceValuesFromBackEnd:values];
            } else {
                refreshTableView = [self.deviceGroup removeExcludesOtherValues];
            }
            // else go ahead and select
            deviceValue = [self.deviceGroup deviceValueForDevice:device
                                                          create:YES
                                                           value:nil];
            [self.deviceGroup addValuesObject:deviceValue];
        } else {
            // unselect - remove
            [self.deviceGroup removeValuesObject:deviceValue];
            [self.managedObjectContext deleteObject:deviceValue];
            [self deleteDeviceValuesFromBackEnd:@[deviceValue]];
        }
        // allow multiple selection
        if (refreshTableView) {
            [tableView reloadData];
        } else {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    return [[WMDeviceCategory deviceCategoryForSortRank:sortRank managedObjectContext:self.managedObjectContext] title];
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    if (self.didCreateGroup) {
        return nil;
    }
    // else
    return @[[NSString stringWithFormat:@"%@/%@", self.deviceGroup.ffUrl, WMDeviceGroupRelationships.values]];
}

- (NSArray *)backendSeedEntityNames
{
    return @[];
}

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

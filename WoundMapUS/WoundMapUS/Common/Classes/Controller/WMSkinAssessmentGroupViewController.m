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
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentCategory.h"
#import "WMSkinAssessment.h"
#import "WMSkinAssessmentValue.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMFatFractal.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

#define kSkinAssessmentDeletedTag 1000

@interface WMSkinAssessmentGroupViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) WMSkinAssessmentGroup *skinAssessmentGroup;

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (readonly, nonatomic) WMSkinAssessmentSummaryViewController *skinAssessmentSummaryViewController;
@property (readonly, nonatomic) WMSkinAssessmentGroupHistoryViewController *skinAssessmentGroupHistoryViewController;

@end

@implementation WMSkinAssessmentGroupViewController

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf.tableView reloadData];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    _skinAssessmentGroup = [WMSkinAssessmentGroup activeSkinAssessmentGroup:patient];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    if (_skinAssessmentGroup) {
        dispatch_block_t block = ^{
            // we want to support cancel, so make sure we have an undoManager
            if (nil == managedObjectContext.undoManager) {
                managedObjectContext.undoManager = [[NSUndoManager alloc] init];
                _removeUndoManagerWhenDone = YES;
            }
            [managedObjectContext.undoManager beginUndoGrouping];
        };
        // values may not have been aquired from back end
        if ([_skinAssessmentGroup.values count] == 0) {
            [ffm updateGrabBags:@[WMSkinAssessmentGroupRelationships.values] aggregator:_skinAssessmentGroup ff:ff completionHandler:^(NSError *error) {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                block();
            }];
        } else {
            block();
        }
    } else {
        _skinAssessmentGroup = [WMSkinAssessmentGroup MR_createInContext:managedObjectContext];
        _skinAssessmentGroup.patient = patient;
        self.didCreateGroup = YES;
        // create on back end
        FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [ff queueGrabBagAddItemAtUri:_skinAssessmentGroup.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.skinAssessmentGroups];
        };
        [ff createObj:_skinAssessmentGroup atUri:[NSString stringWithFormat:@"/%@", [WMSkinAssessmentGroup entityName]] onComplete:onComplete onOffline:onComplete];
        WMInterventionEvent *event = [_skinAssessmentGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
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
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Skin Assessment records.", (long)self.recentlyClosedCount]
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

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMSkinAssessment *skinAssessment = (WMSkinAssessment *)assessmentGroup;
    WMSkinAssessmentValue *skinAssessmentValue = [self.skinAssessmentGroup skinAssessmentValueForSkinAssessment:skinAssessment
                                                                                                         create:NO
                                                                                                          value:nil];
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
                                                                                                          value:nil];
    if (createSkinAssessmentValue) {
        skinAssessmentValue.value = value;
    } else if (nil != skinAssessmentValue) {
        [self.skinAssessmentGroup removeValuesObject:skinAssessmentValue];
        [self.managedObjectContext deleteObject:skinAssessmentValue];
        // update back end
        if (_skinAssessmentGroup.ffUrl) {
            if (skinAssessmentValue.ffUrl) {
                FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                    if (error) {
                        [WMUtilities logError:error];
                    }
                };
                WMFatFractal *ff = [WMFatFractal sharedInstance];
                [ff queueGrabBagRemoveItemAtUri:skinAssessmentValue.ffUrl fromObjAtUri:_skinAssessmentGroup.ffUrl grabBagName:WMSkinAssessmentGroupRelationships.values];
                [ff deleteObj:skinAssessmentValue onComplete:completionHandler];
            }
        }
    }
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:skinAssessment];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark - BaseViewController

- (void)handleBackendDeletedObjectIds:(NSArray *)objectIDs
{
    if ([objectIDs containsObject:[_skinAssessmentGroup objectID]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Another team member has deleted the skin assessment."
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        alertView.tag = kSkinAssessmentDeletedTag;
        [alertView show];
    }
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
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    if (self.didCreateGroup && _skinAssessmentGroup.ffUrl) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        for (WMSkinAssessmentValue *value in _skinAssessmentGroup.values) {
            if (value.ffUrl) {
                [ff grabBagRemove:value from:_skinAssessmentGroup grabBagName:WMSkinAssessmentRelationships.values error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
                [ff deleteObj:value error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
            }
        }
        [ff grabBagRemove:_skinAssessmentGroup from:self.patient grabBagName:WMPatientRelationships.skinAssessmentGroups error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_skinAssessmentGroup error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }
    [self.delegate skinAssessmentGroupViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    if (!_skinAssessmentGroup.hasValues) {
        [self cancelAction:sender];
        return;
    }
    // else
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        managedObjectContext.undoManager = nil;
    }
    [super saveAction:sender];
    // create intervention events before super
    [self.skinAssessmentGroup createEditEventsForParticipant:self.appDelegate.participant];
    // wait for back end calls to complete
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block NSInteger counter = 1;  // update
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        WM_ASSERT_MAIN_THREAD;
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.delegate skinAssessmentGroupViewControllerDidSave:weakSelf];
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
    FFHttpMethodCompletion createOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        WMInterventionEvent *interventionEvent = nil;
        if ([object isKindOfClass:[WMInterventionEvent class]]) {
            interventionEvent = (WMInterventionEvent *)object;
        } else {
            FFQueuedOperation *q = (FFQueuedOperation *)object;
            interventionEvent = (WMInterventionEvent *)q.queuedObj;
        }
        [ff queueGrabBagAddItemAtUri:interventionEvent.ffUrl toObjAtUri:participant.ffUrl grabBagName:WMParticipantRelationships.interventionEvents];
        [ff queueGrabBagAddItemAtUri:interventionEvent.ffUrl toObjAtUri:_skinAssessmentGroup.ffUrl grabBagName:WMSkinAssessmentGroupRelationships.interventionEvents];
        completionHandler(error, object, response);
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
        ++counter;
        [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@", [WMInterventionEvent entityName]] onComplete:createOnComplete onOffline:createOnComplete];
    }
    FFHttpMethodCompletion createValueOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        WMSkinAssessmentValue *value = nil;
        if ([object isKindOfClass:[WMSkinAssessmentValue class]]) {
            value = (WMSkinAssessmentValue *)object;
        } else {
            FFQueuedOperation *q = (FFQueuedOperation *)object;
            value = (WMSkinAssessmentValue *)q.queuedObj;
        }
        [ff queueGrabBagAddItemAtUri:value.ffUrl toObjAtUri:_skinAssessmentGroup.ffUrl grabBagName:WMSkinAssessmentRelationships.values];
        completionHandler(error, object, response);
    };
    for (WMSkinAssessmentValue *value in _skinAssessmentGroup.values) {
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
        [ff createObj:value atUri:[NSString stringWithFormat:@"/%@", [WMSkinAssessmentValue entityName]] onComplete:createValueOnComplete onOffline:createValueOnComplete];
    }
    [ff updateObj:_skinAssessmentGroup onComplete:completionHandler onOffline:completionHandler];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSkinAssessmentDeletedTag) {
        [self cancelAction:nil];
    }
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

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.skinAssessmentGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.skinAssessmentGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                    title:nil
                                                                                valueFrom:nil
                                                                                  valueTo:nil
                                                                                     type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                                  managedObjectContext:self.managedObjectContext]
                                                                              participant:self.appDelegate.participant
                                                                                   create:YES
                                                                     managedObjectContext:self.managedObjectContext];
    DLog(@"Created WMSkinAssessmentInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.skinAssessmentGroup;
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
                                                                                                          value:nil];
    BOOL reloadSection = YES;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    if (nil == skinAssessmentValue) {
        // no skinAssessmentValue for this skinAssessment - add one or make control first responder
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIResponder *responder = [self possibleFirstResponderInCell:cell];
        if (nil == responder) {
            // unselect any other selection in category (section)
            NSArray *values = [self.skinAssessmentGroup removeSkinAssessmentValuesForCategory:skinAssessment.category];
            // update back end
            if (_skinAssessmentGroup.ffUrl) {
                for (WMSkinAssessmentValue *value in values) {
                    if (value.ffUrl) {
                        [ff grabBagRemoveItemAtFfUrl:value.ffUrl fromObjAtFfUrl:_skinAssessmentGroup.ffUrl grabBagName:WMSkinAssessmentGroupRelationships.values onComplete:completionHandler];
                        [ff deleteObj:value onComplete:completionHandler];
                    }
                }
            }
            // go ahead and select
            [self.skinAssessmentGroup skinAssessmentValueForSkinAssessment:skinAssessment
                                                                    create:YES
                                                                     value:nil];
        } else {
            self.indexPathForDelayedFirstResponder = indexPath;
            [responder performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
            reloadSection = NO;
        }
    } else {
        // unselect - remove
        [self.skinAssessmentGroup removeValuesObject:skinAssessmentValue];
        [self.managedObjectContext deleteObject:skinAssessmentValue];
        // update back end
        if (_skinAssessmentGroup.ffUrl) {
            if (skinAssessmentValue.ffUrl) {
                [ff grabBagRemoveItemAtFfUrl:skinAssessmentValue.ffUrl fromObjAtFfUrl:_skinAssessmentGroup.ffUrl grabBagName:WMSkinAssessmentGroupRelationships.values onComplete:completionHandler];
                [ff deleteObj:skinAssessmentValue onComplete:completionHandler];
            }
        }
    }
    // reload section
    if (reloadSection) {
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
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
                                                   managedObjectContext:self.managedObjectContext] title];
}

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    if (self.didCreateGroup) {
        return nil;
    }
    // else
    return [NSString stringWithFormat:@"%@/%@", self.skinAssessmentGroup.ffUrl, WMSkinAssessmentGroupRelationships.values];
}

- (NSArray *)backendSeedEntityNames
{
    return @[];
}

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

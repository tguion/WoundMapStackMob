//
//  WMPsychoSocialGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPsychoSocialGroupViewController.h"
#import "WMPsychoSocialSummaryViewController.h"
#import "WMPsychoSocialGroupHistoryViewController.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMPsychoSocialGroup.h"
#import "WMPsychoSocialItem.h"
#import "WMPsychoSocialValue.h"
#import "WMInterventionStatus.h"
#import "WMInterventionEvent.h"
#import "WMInterventionEventType.h"
#import "WMInterventionEvent.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "PDFRenderer.h"
#import "UIView+Custom.h"
#import "WMDesignUtilities.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMPsychoSocialGroupViewController () <PsychoSocialGroupViewControllerDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (strong, nonatomic) WMPsychoSocialItem *parentPsychoSocialItem;                   // WMPsychoSocialItem that has subcategories or items
@property (readonly, nonatomic) WMPsychoSocialGroupViewController *subitemsViewController;    // view controller for subitems
@property (strong, nonatomic) WMPsychoSocialItem *selectedPsychoSocialItem;                 // selected WMPsychoSocialItem, navigate to subitems
@property (readonly, nonatomic) WMPsychoSocialSummaryViewController *psychoSocialSummaryViewController;
@property (readonly, nonatomic) WMPsychoSocialGroupHistoryViewController *psychoSocialGroupHistoryViewController;
@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (readonly, nonatomic) UILabel *tableHeaderViewLabel;

- (void)grabBagRemovePsychoSocialValues:(NSArray *)values;

@end

@interface WMPsychoSocialGroupViewController (PrivateMethods)
- (void)navigateToSubitems;
- (void)reloadRowsForSelectedPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem previousIndexPath:(NSIndexPath *)previousIndexPath;
@end

@implementation WMPsychoSocialGroupViewController (PrivateMethods)

- (void)navigateToSubitems
{
    WMPsychoSocialGroupViewController *subitemsViewController = self.subitemsViewController;
    subitemsViewController.psychoSocialGroup = self.psychoSocialGroup;
    subitemsViewController.parentPsychoSocialItem = self.selectedPsychoSocialItem;
    [self.navigationController pushViewController:subitemsViewController animated:YES];
}

- (void)reloadRowsForSelectedPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem previousIndexPath:(NSIndexPath *)previousIndexPath
{
    
}

@end

@implementation WMPsychoSocialGroupViewController

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^{
            if (!weakSelf.didCreateGroup) {
                // we want to support cancel, so make sure we have an undoManager
                if (nil == weakSelf.managedObjectContext.undoManager) {
                    weakSelf.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
                    weakSelf.removeUndoManagerWhenDone = YES;
                }
                [weakSelf.managedObjectContext.undoManager beginUndoGrouping];
            }
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.parentPsychoSocialItem.hasSubItems) {
        [self.managedObjectContext.undoManager beginUndoGrouping];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.parentPsychoSocialItem.subitemPrompt length] > 0) {
        self.tableView.tableHeaderView = self.tableHeaderView;
        self.tableHeaderViewLabel.text = self.parentPsychoSocialItem.subitemPrompt;
    }
    [super viewWillAppear:animated];
    if (nil != self.selectedPsychoSocialItem) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.selectedPsychoSocialItem];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %d open Psychosocial records. A new Psychosocial Record has been created for you.", self.recentlyClosedCount]
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

- (void)clearViewReferences
{
    [super clearViewReferences];
    _tableHeaderView = nil;
}

- (void)clearDataCache
{
    [super clearDataCache];
    _psychoSocialGroup = nil;
    _parentPsychoSocialItem = nil;
    _selectedPsychoSocialItem = nil;
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return YES;
}

- (void)updateToolbarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:8];
    if ([WMPsychoSocialGroup psychoSocialGroupsHaveHistory:self.patient]) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showPsychoSocialGroupHistoryAction:)]];
    }
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    NSString *title = (self.psychoSocialGroup.status.isActive ? [NSString stringWithFormat:@"Current Status: %@", self.psychoSocialGroup.status.title]:self.psychoSocialGroup.status.title);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(updateStatusPsychoSocialGroupAction:)];
    barButtonItem.enabled = self.psychoSocialGroup.status.isActive;
    [items addObject:barButtonItem];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    if (self.psychoSocialGroup.hasInterventionEvents) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showPsychoSocialGroupEventsAction:)]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    self.title = (nil == _parentPsychoSocialItem ? @"Psychosocial":@"Answer");
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)updateUIForSearch
{
    [super updateUIForSearch];
    self.title = @"Search Definitions";
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMPsychoSocialItem *psychoSocialItem = (WMPsychoSocialItem *)assessmentGroup;
    WMPsychoSocialValue *psychoSocialValue = nil;
    if (psychoSocialItem.groupValueTypeCode == GroupValueTypeCodeQuestionNavigateOptions) {
        // use the value for selected subitems, but first check if there is any data
        if ([self.psychoSocialGroup subitemValueCountForPsychoSocialItem:psychoSocialItem] == 0) {
            return nil;
        }
        // else
        return [NSString stringWithFormat:@"%d", [self.psychoSocialGroup updatedScoreForPsychoSocialItem:psychoSocialItem]];
    }
    // else
    psychoSocialValue = [self.psychoSocialGroup psychoSocialValueForPsychoSocialGroup:self.psychoSocialGroup
                                                                     psychoSocialItem:psychoSocialItem
                                                                               create:NO
                                                                                value:nil];
    if (nil == psychoSocialValue) {
        return nil;
    }
    // else
    if (assessmentGroup.groupValueTypeCode == GroupValueTypeCodeSelect) {
        return psychoSocialValue;
    }
    // else
    return psychoSocialValue.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    WMPsychoSocialItem *psychoSocialItem = (WMPsychoSocialItem *)assessmentGroup;
    WMPsychoSocialItem *parentPsychoSocialItem = psychoSocialItem.parentItem;
    BOOL createValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createValue = [value length] > 0;
    }
    if (createValue) {
        // unselect any other selection in parent item
        if (nil != parentPsychoSocialItem && !parentPsychoSocialItem.allowMultipleChildSelection) {
            NSArray *values = [self.psychoSocialGroup removePsychoSocialValuesForPsychoSocialItem:parentPsychoSocialItem];
            // update back end
            [self grabBagRemovePsychoSocialValues:values];
        }
    }
    WMPsychoSocialValue *psychoSocialValue = [self.psychoSocialGroup psychoSocialValueForPsychoSocialGroup:self.psychoSocialGroup
                                                                                          psychoSocialItem:psychoSocialItem
                                                                                                    create:createValue
                                                                                                     value:nil];
    if (createValue) {
        psychoSocialValue.value = value;
    } else if (nil != psychoSocialValue) {
        [self.psychoSocialGroup removeValuesObject:psychoSocialValue];
        [self.managedObjectContext deleteObject:psychoSocialValue];
        // update back end
        [self grabBagRemovePsychoSocialValues:@[psychoSocialValue]];
    }
}

#pragma mark - Core

- (UILabel *)tableHeaderViewLabel
{
    return (UILabel *)[self.tableHeaderView viewWithTag:1000];
}

- (WMPsychoSocialGroup *)psychoSocialGroup
{
    if (nil == _psychoSocialGroup) {
        WMPsychoSocialGroup *psychoSocialGroup = [WMPsychoSocialGroup activePsychoSocialGroup:self.patient];
        if (nil == psychoSocialGroup) {
            psychoSocialGroup = [WMPsychoSocialGroup psychoSocialGroupForPatient:self.patient];
            self.didCreateGroup = YES;
            WMInterventionEvent *event = [psychoSocialGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                      path:nil
                                                                                     title:nil
                                                                                 valueFrom:nil
                                                                                   valueTo:nil
                                                                                      type:[WMInterventionEventType interventionEventTypeForTitle:kInterventionEventTypePlan
                                                                                                                                           create:YES
                                                                                                                             managedObjectContext:self.managedObjectContext]
                                                                               participant:self.appDelegate.participant
                                                                                    create:YES
                                                                      managedObjectContext:self.managedObjectContext];
            DLog(@"Created event %@", event.eventType.title);
            // update backend
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            __weak __typeof(&*self)weakSelf = self;
            FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    [ff grabBagAddItemAtFfUrl:psychoSocialGroup.ffUrl
                                 toObjAtFfUrl:weakSelf.patient.ffUrl
                                  grabBagName:WMPatientRelationships.psychosocialGroups
                                   onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                       if (error) {
                                           [WMUtilities logError:error];
                                       }
                                   }];
                }
            };
            [ff createObj:psychoSocialGroup
                    atUri:[NSString stringWithFormat:@"/%@", [WMPsychoSocialGroup entityName]]
               onComplete:block
                onOffline:block];
        }
        self.psychoSocialGroup = psychoSocialGroup;
    }
    return _psychoSocialGroup;
}

- (void)grabBagRemovePsychoSocialValues:(NSArray *)values
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    for (WMPsychoSocialValue *value in values) {
        if (value.ffUrl) {
            [ff grabBagRemoveItemAtFfUrl:value.ffUrl
                          fromObjAtFfUrl:_psychoSocialGroup.ffUrl
                             grabBagName:WMPsychoSocialGroupRelationships.values
                              onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                  if (error) {
                                      [WMUtilities logError:error];
                                  } else {
                                      [ff deleteObj:value onComplete:block onOffline:block];
                                  }
                              }];
        }
    }
}

- (WMPsychoSocialGroupViewController *)subitemsViewController
{
    WMPsychoSocialGroupViewController *subitemsViewController = [[WMPsychoSocialGroupViewController alloc] initWithNibName:@"WMPsychoSocialGroupViewController" bundle:nil];
    subitemsViewController.delegate = self;
    return subitemsViewController;
}

- (WMPsychoSocialSummaryViewController *)psychoSocialSummaryViewController
{
    WMPsychoSocialSummaryViewController *psychoSocialSummaryViewController = [[WMPsychoSocialSummaryViewController alloc] initWithNibName:@"WMPsychoSocialSummaryViewController" bundle:nil];
    return psychoSocialSummaryViewController;
}

- (WMPsychoSocialGroupHistoryViewController *)psychoSocialGroupHistoryViewController
{
    WMPsychoSocialGroupHistoryViewController *psychoSocialGroupHistoryViewController = [[WMPsychoSocialGroupHistoryViewController alloc] initWithNibName:@"WMPsychoSocialGroupHistoryViewController" bundle:nil];
    return psychoSocialGroupHistoryViewController;
}

#pragma mark - Actions

- (IBAction)showPsychoSocialGroupHistoryAction:(id)sender
{
    [self.navigationController pushViewController:self.psychoSocialGroupHistoryViewController animated:YES];
}

- (IBAction)updateStatusPsychoSocialGroupAction:(id)sender
{
    [self presentInterventionStatusViewController];
}

- (IBAction)showPsychoSocialGroupEventsAction:(id)sender
{
    [self presentInterventionEventViewController];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    BOOL hasValues = [_psychoSocialGroup.values count] > 0;
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
        [managedObjectContext deleteObject:_psychoSocialGroup];
        // update backend
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        [ff grabBagRemove:_psychoSocialGroup from:self.patient grabBagName:WMPatientRelationships.psychosocialGroups error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_psychoSocialGroup error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        _psychoSocialGroup = nil;
        self.didCreateGroup = NO;
    }
    [self.delegate psychoSocialGroupViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    if (self.selectedPsychoSocialItem) {
        // just pull down UI
        [self.delegate psychoSocialGroupViewControllerDidFinish:self];
        return;
    }
    // else
    BOOL hasValues = [_psychoSocialGroup.values count] > 0;
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
    [_psychoSocialGroup createEditEventsForParticipant:participant];
    // update backend
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        WM_ASSERT_MAIN_THREAD;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [weakSelf.delegate psychoSocialGroupViewControllerDidFinish:weakSelf];
    };
    // update back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error && counter) {
            counter = 0;
            block();
        } else {
            --counter;
            if (counter == 0) {
                block();
            }
        }
    };
    for (WMInterventionEvent *interventionEvent in participant.interventionEvents) {
        if (interventionEvent.ffUrl) {
            continue;
        }
        // else
        ++counter;
        ++counter;
        [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@", [WMInterventionEvent entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:participant.ffUrl grabBagName:WMParticipantRelationships.interventionEvents onComplete:completionHandler];
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:_psychoSocialGroup.ffUrl grabBagName:WMPsychoSocialGroupRelationships.interventionEvents onComplete:completionHandler];
        }];
    }
    for (WMPsychoSocialValue *value in _psychoSocialGroup.values) {
        ++counter;
        [ff createObj:value atUri:[NSString stringWithFormat:@"/%@", [WMPsychoSocialValue entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [ff grabBagAddItemAtFfUrl:value.ffUrl toObjAtFfUrl:_psychoSocialGroup.ffUrl grabBagName:WMPsychoSocialGroupRelationships.values onComplete:completionHandler];
        }];
    }
    ++counter;
    [ff updateObj:_psychoSocialGroup onComplete:completionHandler];
}

#pragma mark - AssessmentTableViewCellDelegate

- (CGFloat)updatedHeightForOpenState
{
    CGFloat height = 44.0;
    if (nil != self.selectedPsychoSocialItem) {
        // resize if open
        id<AssessmentGroup> assessmentGroup = (id<AssessmentGroup>)self.selectedPsychoSocialItem;
        BOOL openFlag = [self isCellOpenForAssessmentGroup:assessmentGroup];
        if (openFlag && ![self isHeightRegisteredForOpenState:openFlag assessmentGroup:assessmentGroup]) {
            height = [self preferredHeightWithBaseHeight:[WMAssessmentTableViewCell defaultPreferredHeightForAssessmentGroup:assessmentGroup width:(UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.separatorInset).size.width)]
                                                   width:self.lastWidthForSummaryView
                                                openFlag:openFlag assessmentGroup:assessmentGroup];
        }
    }
    return height;
}

- (CGFloat)preferredHeightWithBaseHeight:(CGFloat)baseHeight width:(CGFloat)width openFlag:(BOOL)openFlag assessmentGroup:(id)assessmentGroup
{
    NSAssert1([assessmentGroup isKindOfClass:[WMPsychoSocialItem class]], @"Wrong class. Expected WMPsychoSocialItem, %@", assessmentGroup);
    //    WMPsychoSocialItem *psychoSocialItem = (WMPsychoSocialItem *)assessmentGroup;
    //    CGRect rect = CGRectMake(0.0, 0.0, width, 5000.0);
    return baseHeight;// TODO finish draw of PsychoSocial item
    //    return (baseHeight + [self.renderer drawChildCarePlanValuesForCarePlanGroup:self.carePlanGroup
    //                                                               carePlanCategory:carePlanCategory
    //                                                                         inRect:rect
    //                                                                           draw:NO] + 8.0);
}

- (void)drawSummaryViewForAssessmentGroup:(id)assessmentGroup inRect:(CGRect)rect
{
    //    NSAssert1([assessmentGroup isKindOfClass:[WMCarePlanCategory class]], @"Wrong class. Expected WMCarePlanCategory, %@", assessmentGroup);
    //    WMCarePlanCategory *carePlanCategory = (WMCarePlanCategory *)assessmentGroup;
    //    [self.renderer drawChildCarePlanValuesForCarePlanGroup:self.carePlanGroup
    //                                          carePlanCategory:carePlanCategory
    //                                                    inRect:rect
    //                                                      draw:YES];
}

#pragma mark - PsychoSocialGroupViewControllerDelegate

- (void)psychoSocialGroupViewControllerDidFinish:(WMPsychoSocialGroupViewController *)viewController
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[self.fetchedResultsController indexPathForObject:_selectedPsychoSocialItem]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    self.selectedPsychoSocialItem = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)psychoSocialGroupViewControllerDidCancel:(WMPsychoSocialGroupViewController *)viewController
{
    self.selectedPsychoSocialItem = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"Psychosocial Summary";
}

- (UIViewController *)summaryViewController
{
    WMPsychoSocialSummaryViewController *psychoSocialSummaryViewController = self.psychoSocialSummaryViewController;
    psychoSocialSummaryViewController.psychoSocialGroup = self.psychoSocialGroup;
    return psychoSocialSummaryViewController;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return self.psychoSocialGroup.status;
}

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.psychoSocialGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.psychoSocialGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                   path:nil
                                                                                  title:nil
                                                                              valueFrom:nil
                                                                                valueTo:nil
                                                                                   type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                                managedObjectContext:self.managedObjectContext]
                                                                            participant:self.appDelegate.participant
                                                                                 create:YES
                                                                   managedObjectContext:self.managedObjectContext];
    DLog(@"Created WMPsychoSocialInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.psychoSocialGroup;
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
    return (self.psychoSocialGroup.status.isActive ? indexPath:nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMPsychoSocialItem *psychoSocialItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // IAP: check if category requires IAP
    self.selectedPsychoSocialItem = psychoSocialItem;
    if (psychoSocialItem.hasSubItems) {
        [self navigateToSubitems];
    } else {
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
            NSIndexPath *previousIndexPath = nil;
            WMPsychoSocialValue *psychoSocialValue = [self.psychoSocialGroup psychoSocialValueForPsychoSocialGroup:self.psychoSocialGroup
                                                                                                  psychoSocialItem:psychoSocialItem
                                                                                                            create:NO
                                                                                                             value:nil];
            if (nil == psychoSocialValue) {
                // check if need to remove other selection
                if (nil != psychoSocialItem.parentItem && !psychoSocialItem.parentItem.allowMultipleChildSelection) {
                    // else save current selection if needed
                    WMPsychoSocialValue *previousPsychoSocialValue = [self.psychoSocialGroup psychoSocialValueForParentItem:psychoSocialItem.parentItem];
                    if (nil != previousPsychoSocialValue) {
                        previousIndexPath = [self.fetchedResultsController indexPathForObject:previousPsychoSocialValue.psychoSocialItem];
                        // unselect - remove
                        [self.psychoSocialGroup removeValuesObject:previousPsychoSocialValue];
                        [self.managedObjectContext deleteObject:previousPsychoSocialValue];
                        [self grabBagRemovePsychoSocialValues:@[previousPsychoSocialValue]];
                    }
                }
                // go ahead and select
                psychoSocialValue = [self.psychoSocialGroup psychoSocialValueForPsychoSocialGroup:self.psychoSocialGroup
                                                                                 psychoSocialItem:psychoSocialItem
                                                                                           create:YES
                                                                                            value:nil];
                [self.psychoSocialGroup addValuesObject:psychoSocialValue];
            } else {
                // unselect - remove
                [self.psychoSocialGroup removeValuesObject:psychoSocialValue];
                [self.managedObjectContext deleteObject:psychoSocialValue];
                [self grabBagRemovePsychoSocialValues:@[psychoSocialValue]];
            }
            // don't allow multiple selection
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, previousIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
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
	return sectionInfo.name;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [super configureCell:cell atIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    return [NSString stringWithFormat:@"/%@", [WMPsychoSocialItem entityName]];
}

- (NSString *)backendSeedEntityName
{
    return [WMPsychoSocialItem entityName];
}

- (NSString *)fetchedResultsControllerEntityName
{
    if (self.isSearchActive) {
        return @"WMDefinition";
    }
    // else
	return @"WMPsychoSocialItem";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundCarePlan];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [WMPsychoSocialItem predicateForParent:self.parentPsychoSocialItem woundType:self.wound.woundType];
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    NSArray *sortDescriptors = nil;
    if (self.isSearchActive) {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES]];
    } else {
        sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES], nil];
    }
    return sortDescriptors;
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
	return @"sectionTitle";
}

@end

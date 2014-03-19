//
//  WMWoundMeasurementGroupViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/25/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundMeasurementGroupViewController.h"
#import "WMSelectAmountQualifierViewController.h"
#import "WMSelectWoundOdorViewController.h"
#import "WMUndermineTunnelViewController.h"
#import "WMNoteViewController.h"
#import "WMAdjustAlpaView.h"
#import "WMWoundMeasurementSummaryViewController.h"
#import "WMWoundMeasurementGroupHistoryViewController.h"
#import "WMWoundPhoto.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurement.h"
#import "WMWoundMeasurementValue.h"
#import "WMAmountQualifier.h"
#import "WMWoundOdor.h"
#import "WMInterventionEvent.h"
#import "WMWoundMeasurementIntEvent.h"
#import "WMInterventionEventType.h"
#import "WMInterventionStatus.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMPolicyManager.h"
#import "WMNavigationCoordinator.h"
#import "WMDesignUtilities.h"
#import "UIView+Custom.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMWoundMeasurementGroupViewController () <AdjustAlpaViewDelegate, WoundMeasurementGroupViewControllerDelegate, SelectAmountQualifierViewControllerDelegate, SelectWoundOdorViewControllerDelegate, UndermineTunnelViewControllerDelegate, NoteViewControllerDelegate>

@property (weak, nonatomic) WMAdjustAlpaView *adjustAlpaView;
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (strong, nonatomic) NSManagedObjectID *woundMeasurementGroupObjectID;
@property (strong, nonatomic) NSManagedObjectID *parentWoundMeasurementObjectID;
@property (readonly, nonatomic) WMWoundMeasurementGroupViewController *woundMeasurementViewController;
@property (strong, nonatomic) WMWoundMeasurement *selectedWoundMeasurement;
@property (strong, nonatomic) NSManagedObjectID *selectedWoundMeasurementObjectID;
@property (readonly, nonatomic) WMSelectAmountQualifierViewController *selectAmountQualifierViewController;
@property (readonly, nonatomic) WMSelectWoundOdorViewController *selectWoundOdorViewController;
@property (readonly, nonatomic) WMUndermineTunnelViewController *undermineTunnelViewController;
@property (readonly, nonatomic) WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController;
@property (readonly, nonatomic) WMWoundMeasurementGroupHistoryViewController *woundMeasurementGroupHistoryViewController;
@property (readonly, nonatomic) WMNoteViewController *noteViewController;

- (IBAction)normalizePercentageAction:(id)sender;

@end

@interface WMWoundMeasurementGroupViewController (PrivateMethods)
- (void)reloadRowsForSelectedWoundMeasurement:(WMWoundMeasurement *)selectedWoundMeasurement previousIndexPath:(NSIndexPath *)previousIndexPath;
- (void)navigateToChildrenWoundMeasurementsForParentWoundMeasurement:(WMWoundMeasurement *)woundMeasurement;
- (void)navigateToAmountsForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement;
- (void)navigateToOdorsForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement;
- (void)navigateToUndermineTunnelViewController:(WMWoundMeasurement *)woundMeasurement;
- (void)navigateToNoteViewController:(WMWoundMeasurement *)woundMeasurement;
@end

@implementation WMWoundMeasurementGroupViewController (PrivateMethods)

- (void)reloadRowsForSelectedWoundMeasurement:(WMWoundMeasurement *)selectedWoundMeasurement previousIndexPath:(NSIndexPath *)previousIndexPath
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:selectedWoundMeasurement];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, previousIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)navigateToChildrenWoundMeasurementsForParentWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    [self.managedObjectContext.undoManager beginUndoGrouping];
    WMWoundMeasurementGroupViewController *woundMeasurementViewController = self.woundMeasurementViewController;
    woundMeasurementViewController.woundMeasurementGroup = self.woundMeasurementGroup;
    woundMeasurementViewController.parentWoundMeasurement = woundMeasurement;
    [self.navigationController pushViewController:woundMeasurementViewController animated:YES];
}

- (void)navigateToAmountsForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    self.selectedWoundMeasurement = woundMeasurement;
    [self.navigationController pushViewController:self.selectAmountQualifierViewController animated:YES];
}

- (void)navigateToOdorsForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    self.selectedWoundMeasurement = woundMeasurement;
    [self.navigationController pushViewController:self.selectWoundOdorViewController animated:YES];
}

- (void)navigateToUndermineTunnelViewController:(WMWoundMeasurement *)woundMeasurement
{
    WMUndermineTunnelViewController *undermineTunnelViewController = self.undermineTunnelViewController;
    undermineTunnelViewController.woundMeasurementGroup = self.woundMeasurementGroup;
    undermineTunnelViewController.showCancelButton = YES;
    [self.navigationController pushViewController:undermineTunnelViewController animated:YES];
}

- (void)navigateToNoteViewController:(WMWoundMeasurement *)woundMeasurement
{
    self.selectedWoundMeasurement = woundMeasurement;
    [self.navigationController pushViewController:self.noteViewController animated:YES];
}

@end

@implementation WMWoundMeasurementGroupViewController

@synthesize adjustAlpaView=_adjustAlpaView, tableFooterView=_tableFooterView;
@synthesize delegate;
@synthesize woundMeasurementGroup=_woundMeasurementGroup, woundMeasurementGroupObjectID=_woundMeasurementGroupObjectID;
@synthesize parentWoundMeasurement=_parentWoundMeasurement, parentWoundMeasurementObjectID=_parentWoundMeasurementObjectID;
@synthesize selectedWoundMeasurement=_selectedWoundMeasurement, selectedWoundMeasurementObjectID=_selectedWoundMeasurementObjectID;
@dynamic selectedAmountQualifier, selectedWoundOdor;

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // do this here
    if (self.parentWoundMeasurement.normalizeMeasurements) {
        self.tableView.tableFooterView = self.tableFooterView;
    } else {
        self.tableView.tableFooterView = nil;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.woundMeasurementGroup.woundPhoto.thumbnail];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.tableView.backgroundView = imageView;
    self.tableView.backgroundView.alpha = kInitialBackgroundImageAlpha;
    // place WMAdjustAlpaView
    if (nil == _adjustAlpaView) {
        CGRect aFrame = CGRectMake(0.0, 106.0, 32.0, CGRectGetHeight(self.view.bounds) - 144.0);
        WMAdjustAlpaView *adjustAlpaView = [[WMAdjustAlpaView alloc] initWithFrame:aFrame delegate:self];
        adjustAlpaView.contentMode = UIViewContentModeRedraw;
        [self.view addSubview:adjustAlpaView];
        [adjustAlpaView performSelector:@selector(flashViewAlpha) withObject:nil afterDelay:0.0];
        _adjustAlpaView = adjustAlpaView;
    }
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Wound Assessment records. A new Wound Assessment has been created for you.", (long)self.recentlyClosedCount]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        self.recentlyClosedCount = 0;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.adjustAlpaView reset];
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.tableView.backgroundView.hidden = YES;
        self.adjustAlpaView.hidden = YES;
    } else {
        self.tableView.backgroundView.hidden = NO;
        self.adjustAlpaView.hidden = NO;
    }
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    if (nil != _woundMeasurementGroupObjectID && ![[_woundMeasurementGroup objectID] isTemporaryID]) {
        _woundMeasurementGroupObjectID = [_woundMeasurementGroup objectID];
        _woundMeasurementGroup = nil;
    }
    if (nil != _parentWoundMeasurementObjectID && ![[_parentWoundMeasurement objectID] isTemporaryID]) {
        _parentWoundMeasurementObjectID = [_parentWoundMeasurement objectID];
        _parentWoundMeasurement = nil;
    }
    if (nil != _selectedWoundMeasurementObjectID && ![[_selectedWoundMeasurement objectID] isTemporaryID]) {
        _selectedWoundMeasurementObjectID = [_selectedWoundMeasurement objectID];
        _selectedWoundMeasurement = nil;
    }
}

// clear any strong references to views
- (void)clearViewReferences
{
    [super clearViewReferences];
    _tableFooterView = nil;
}

- (void)clearDataCache
{
    [super clearDataCache];
    _woundMeasurementGroup = nil;
    _woundMeasurementGroupObjectID = nil;
    _parentWoundMeasurement = nil;
    _parentWoundMeasurementObjectID = nil;
    _selectedWoundMeasurement = nil;
    _selectedWoundMeasurementObjectID = nil;
}

#pragma mark - Core

- (WMWoundMeasurementGroup *)woundMeasurementGroup
{
    if (nil == _woundMeasurementGroup) {
        WMWoundMeasurementGroup *woundMeasurementGroup = nil;
        if (nil == _woundMeasurementGroupObjectID) {
            if (nil != self.woundPhoto) {
                woundMeasurementGroup = [WMWoundMeasurementGroup activeWoundMeasurementGroupForWoundPhoto:self.woundPhoto];
            }
            if (nil == woundMeasurementGroup) {
                woundMeasurementGroup = [WMWoundMeasurementGroup woundMeasurementGroupInstanceForWound:self.wound woundPhoto:self.woundPhoto];
                WMInterventionEvent *event = [woundMeasurementGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
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
            }
        } else {
            woundMeasurementGroup = (WMWoundMeasurementGroup *)[self.managedObjectContext objectWithID:_woundMeasurementGroupObjectID];
        }
        self.didCreateGroup = [[woundMeasurementGroup objectID] isTemporaryID];
        _woundMeasurementGroup = woundMeasurementGroup;
    }
    NSAssert(nil != _woundMeasurementGroup, @"Unable to instanciate a WMWoundMeasurementGroup");
    return _woundMeasurementGroup;
}

- (WMWoundMeasurement *)parentWoundMeasurement
{
    if (nil == _parentWoundMeasurement && nil != _parentWoundMeasurementObjectID) {
        _parentWoundMeasurement = (WMWoundMeasurement *)[[self managedObjectContext] objectWithID:_parentWoundMeasurementObjectID];
    }
    return _parentWoundMeasurement;
}

- (WMWoundMeasurementGroupViewController *)woundMeasurementViewController
{
    WMWoundMeasurementGroupViewController *woundMeasurementViewController = [[WMWoundMeasurementGroupViewController alloc] initWithNibName:@"WMWoundMeasurementGroupViewController" bundle:nil];
    woundMeasurementViewController.delegate = self;
    return woundMeasurementViewController;
}

- (WMWoundMeasurement *)selectedWoundMeasurement
{
    if (nil == _selectedWoundMeasurement && nil != _selectedWoundMeasurementObjectID) {
        _selectedWoundMeasurement = (WMWoundMeasurement *)[self.managedObjectContext objectWithID:_selectedWoundMeasurementObjectID];
    }
    return _selectedWoundMeasurement;
}

- (WMSelectAmountQualifierViewController *)selectAmountQualifierViewController
{
    WMSelectAmountQualifierViewController *selectAmountQualifierViewController = [[WMSelectAmountQualifierViewController alloc] initWithNibName:@"WMSelectAmountQualifierViewController" bundle:nil];
    selectAmountQualifierViewController.delegate = self;
    return selectAmountQualifierViewController;
}

- (WMSelectWoundOdorViewController *)selectWoundOdorViewController
{
    WMSelectWoundOdorViewController *selectWoundOdorViewController = [[WMSelectWoundOdorViewController alloc] initWithNibName:@"WMSelectWoundOdorViewController" bundle:nil];
    selectWoundOdorViewController.delegate = self;
    return selectWoundOdorViewController;
}

- (WMUndermineTunnelViewController *)undermineTunnelViewController
{
    WMUndermineTunnelViewController *undermineTunnelViewController = [[WMUndermineTunnelViewController alloc] initWithNibName:@"WMUndermineTunnelViewController" bundle:nil];
    undermineTunnelViewController.delegate = self;
    return undermineTunnelViewController;
}

- (WMWoundMeasurementSummaryViewController *)woundMeasurementSummaryViewController
{
    return [[WMWoundMeasurementSummaryViewController alloc] initWithNibName:@"WMWoundMeasurementSummaryViewController" bundle:nil];
}

- (WMWoundMeasurementGroupHistoryViewController *)woundMeasurementGroupHistoryViewController
{
    return [[WMWoundMeasurementGroupHistoryViewController alloc] initWithNibName:@"WMWoundMeasurementGroupHistoryViewController" bundle:nil];
}

- (WMNoteViewController *)noteViewController
{
    WMNoteViewController *noteViewController = [[WMNoteViewController alloc] initWithNibName:@"WMNoteViewController" bundle:nil];
    noteViewController.delegate = self;
    return noteViewController;
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return YES;
}

- (void)updateToolbarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:8];
    if ([WMWoundMeasurementGroup woundMeasurementGroupsHaveHistoryForWound:self.wound]) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showWoundMeasurementGroupHistoryAction:)]];
    }
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    NSString *title = (self.woundMeasurementGroup.status.isActive ? [NSString stringWithFormat:@"Current Status: %@", self.woundMeasurementGroup.status.title]:self.woundMeasurementGroup.status.title);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(updateStatusWoundMeasurementGroupAction:)];
    barButtonItem.enabled = self.woundMeasurementGroup.status.isActive;
    [items addObject:barButtonItem];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    if (self.woundMeasurementGroup.hasInterventionEvents) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showWoundMeasurementGroupEventsAction:)]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    if (nil != _parentWoundMeasurement) {
        self.title = _parentWoundMeasurement.title;
    } else {
        self.title = @"Wound Assessment";
    }
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)updateUIForSearch
{
    [super updateUIForSearch];
    self.title = @"Search Definitions";
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMWoundMeasurement *woundMeasurement = (WMWoundMeasurement *)assessmentGroup;
    WMWoundMeasurementValue *value = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:woundMeasurement
                                                                                                   create:NO
                                                                                                    value:nil];
    if (nil == value && !woundMeasurement.hasChildrenWoundMeasurements) {
        return nil;
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeSelect) {
        return value;
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToOptions) {
        // show summary of children values
        return [self.woundMeasurementGroup displayValueForWoundMeasurement:woundMeasurement];
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToAmounts) {
        return value.amountQualifier.title;
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToOdors) {
        return value.odor.title;
    }
    // else
    return value.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    WMWoundMeasurement *woundMeasurement = (WMWoundMeasurement *)assessmentGroup;
    WMWoundMeasurement *parentWoundMeasurement = woundMeasurement.parentMeasurement;
    BOOL createValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createValue = [value length] > 0;
    }
    BOOL reloadSection = NO;
    if (createValue && nil != parentWoundMeasurement && !parentWoundMeasurement.allowMultipleChildSelection) {
        // unselect any other selection in category (section)
        [self.woundMeasurementGroup removeWoundMeasurementValuesForParentWoundMeasurement:parentWoundMeasurement];
        reloadSection = YES;
    }
    WMWoundMeasurementValue *woundMeasurementValue = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:woundMeasurement
                                                                                                                   create:createValue
                                                                                                                    value:nil];
    if (createValue && [value isKindOfClass:[NSString class]]) {
        woundMeasurementValue.value = value;
    } else if (!createValue && nil != woundMeasurementValue) {
        [self.woundMeasurementGroup removeValuesObject:woundMeasurementValue];
        [self.managedObjectContext deleteObject:woundMeasurementValue];
    }
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:woundMeasurement];
    if (reloadSection) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else if ([self shouldShowSelectionImageForAssessmentGroup:woundMeasurement]) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UIKeyboardType)keyboardTypeForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMWoundMeasurement *woundMeasurement = (WMWoundMeasurement *)assessmentGroup;
    UIKeyboardType keyboardType = [woundMeasurement.keyboardType intValue];
    if (self.isIPadIdiom && keyboardType == UIKeyboardTypeDecimalPad) {
        keyboardType = UIKeyboardTypeNumberPad;
    }
    return keyboardType;
}

#pragma mark - BaseViewController

#pragma mark - Actions

- (IBAction)showWoundMeasurementGroupHistoryAction:(id)sender
{
    [self.navigationController pushViewController:self.woundMeasurementGroupHistoryViewController animated:YES];
}

- (IBAction)updateStatusWoundMeasurementGroupAction:(id)sender
{
    [self presentInterventionStatusViewController];
}

- (IBAction)showWoundMeasurementGroupEventsAction:(id)sender
{
    [self presentInterventionEventViewController];
}

- (IBAction)normalizePercentageAction:(id)sender
{
    [self.woundMeasurementGroup normalizeInputsForParentWoundMeasurement:self.parentWoundMeasurement];
    [self.tableView.visibleCells makeObjectsPerformSelector:@selector(updateContentForAssessmentGroup)];
}

- (IBAction)saveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [super saveAction:sender];
    // create intervention events before super
    [self.woundMeasurementGroup createEditEventsForParticipant:self.appDelegate.participant];
    // allow delegate to dismiss
    [self.delegate woundMeasurementGroupViewControllerDidFinish:self];
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
    [self.delegate woundMeasurementGroupViewControllerDidCancel:self];
}

#pragma mark - AdjustAlpaViewDelegate

- (CGFloat)initialAlpha
{
    return  kInitialBackgroundImageAlpha;
}

- (void)adjustAlpaView:(WMAdjustAlpaView *)adjustAlpaView didUpdateAlpha:(CGFloat)alpha
{
    self.tableView.backgroundView.alpha = alpha;
}

#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"Assessment Summary";
}

- (UIViewController *)summaryViewController
{
    WMWoundMeasurementSummaryViewController *woundMeasurementSummaryViewController = self.woundMeasurementSummaryViewController;
    woundMeasurementSummaryViewController.woundMeasurementGroup = self.woundMeasurementGroup;
    return woundMeasurementSummaryViewController;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return self.woundMeasurementGroup.status;
}

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.woundMeasurementGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.woundMeasurementGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                      title:nil
                                                                                  valueFrom:nil
                                                                                    valueTo:nil
                                                                                       type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                                    managedObjectContext:self.managedObjectContext]
                                                                                participant:self.appDelegate.participant
                                                                                     create:YES
                                                                       managedObjectContext:self.managedObjectContext];
    DLog(@"Created WCWoundMeasurementInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return (id<AssessmentGroup>)self.woundMeasurementGroup;
}

#pragma mark - UndermineTunnelViewControllerDelegate

// TODO - move to area view controller
- (void)undermineTunnelViewControllerDidDone:(WMUndermineTunnelViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    // clear - dont' allow refech data
    [viewController clearViewReferences];
    [viewController clearAllReferences];
}

- (void)undermineTunnelViewControllerDidCancel:(WMUndermineTunnelViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    // clear - dont' allow refech data
    [viewController clearViewReferences];
    [viewController clearAllReferences];
}

#pragma mark - SelectAmountQualifierViewControllerDelegate

- (WMAmountQualifier *)selectedAmountQualifier
{
    WMWoundMeasurementValue *value = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:self.selectedWoundMeasurement
                                                                                                   create:NO
                                                                                                    value:nil];
    return value.amountQualifier;
}

- (void)selectAmountQualifierViewController:(WMSelectAmountQualifierViewController *)viewController didSelectQualifierAmount:(WMAmountQualifier *)amount
{
    WMWoundMeasurementValue *value = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:self.selectedWoundMeasurement
                                                                                                   create:YES
                                                                                                    value:nil];
    value.amountQualifier = amount;
    [self.navigationController popViewControllerAnimated:YES];
    // reload the section if only one selection allowed
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.fetchedResultsController indexPathForObject:self.selectedWoundMeasurement]] withRowAnimation:UITableViewRowAnimationFade];
    _selectedWoundMeasurement = nil;
    // clear
    [viewController clearAllReferences];
}

- (void)selectAmountQualifierViewControllerDidCancel:(WMSelectAmountQualifierViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    _selectedWoundMeasurement = nil;
    // clear
    [viewController clearAllReferences];
}

#pragma mark - SelectWoundOdorViewControllerDelegate

- (WMWoundOdor *)selectedWoundOdor
{
    WMWoundMeasurementValue *value = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:self.selectedWoundMeasurement
                                                                                                   create:NO
                                                                                                    value:nil];
    return value.odor;
}

- (void)selectWoundOdorViewController:(WMSelectWoundOdorViewController *)viewController didSelectWoundOdor:(WMWoundOdor *)woundOdor
{
    WMWoundMeasurementValue *value = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:self.selectedWoundMeasurement
                                                                                                   create:YES
                                                                                                    value:nil];
    value.odor = woundOdor;
    [self.navigationController popViewControllerAnimated:YES];
    // reload the section if only one selection allowed
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.fetchedResultsController indexPathForObject:self.selectedWoundMeasurement]] withRowAnimation:UITableViewRowAnimationFade];
    _selectedWoundMeasurement = nil;
    // clear
    [viewController clearAllReferences];
}

- (void)selectWoundOdorViewControllerDidCancel:(WMSelectWoundOdorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    _selectedWoundMeasurement = nil;
    // clear
    [viewController clearAllReferences];
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [self.managedObjectContext MR_saveOnlySelfAndWait];
    [self.navigationController popViewControllerAnimated:YES];
    // clear
    [viewController clearAllReferences];
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    // clear
    [viewController clearAllReferences];
}

#pragma mark - NoteViewControllerDelegate

- (NSString *)note
{
    WMWoundMeasurementValue *value = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:self.selectedWoundMeasurement
                                                                                                   create:NO
                                                                                                    value:nil];
    return value.value;
}

- (NSString *)label
{
    return self.selectedWoundMeasurement.placeHolder;
}

- (void)noteViewController:(WMNoteViewController *)viewController didUpdateNote:(NSString *)note
{
    WMWoundMeasurementValue *value = [self.woundMeasurementGroup woundMeasurementValueForWoundMeasurement:self.selectedWoundMeasurement
                                                                                                   create:YES
                                                                                                    value:nil];
    value.value = note;
    [self.navigationController popViewControllerAnimated:YES];
    // reload the section if only one selection allowed
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.fetchedResultsController indexPathForObject:self.selectedWoundMeasurement]] withRowAnimation:UITableViewRowAnimationFade];
    self.selectedWoundMeasurement = nil;
}

- (void)noteViewControllerDidCancel:(WMNoteViewController *)viewController withNote:(NSString *)note
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // determine if we are selecting a child measurement, or navigating to amount or odor
    WMWoundMeasurement *woundMeasurement = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (woundMeasurement.hasChildrenWoundMeasurements) {
        // navigate to children
        [self navigateToChildrenWoundMeasurementsForParentWoundMeasurement:woundMeasurement];
        return;
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToAmounts) {
        [self navigateToAmountsForWoundMeasurement:woundMeasurement];
        return;
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToOdors) {
        [self navigateToOdorsForWoundMeasurement:woundMeasurement];
        return;
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeUndermineTunnel) {
        [self navigateToUndermineTunnelViewController:woundMeasurement];
        return;
    }
    // else
    if (woundMeasurement.groupValueTypeCode == GroupValueTypeCodeNavigateToNote) {
        [self navigateToNoteViewController:woundMeasurement];
        return;
    }
    // check for textField
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = [self textFieldForTableViewCell:cell];
    if (nil != textField) {
        self.indexPathForDelayedFirstResponder = indexPath;
        [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
    } else {
        // else update
        [self updateAssessmentGroup:woundMeasurement withValue:woundMeasurement];
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

//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
//{
//    [super configureCell:cell atIndexPath:indexPath];
//    WMWoundMeasurement *woundMeasurement = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    if ([self shouldShowSelectionImageForAssessmentGroup:woundMeasurement]) {
//        if ([self.woundMeasurementGroup hasWoundMeasurementValuesForWoundMeasurementAndChildren:woundMeasurement]) {
//            cell.imageView.image = [DesignUtilities selectedWoundTableCellImage];
//        } else {
//            cell.imageView.image = [DesignUtilities unselectedWoundTableCellImage];
//        }
//    }
//}

- (NSInteger)selectionCountForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    NSInteger count = 0;
    WMWoundMeasurement *woundMeasurement = (WMWoundMeasurement *)assessmentGroup;
    if ([self shouldShowSelectionImageForAssessmentGroup:woundMeasurement]) {
        if ([self.woundMeasurementGroup hasWoundMeasurementValuesForWoundMeasurementAndChildren:woundMeasurement]) {
            count = 1;
        }
    } else {
        count = NSNotFound;
    }
    return count;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMWoundMeasurement");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundAssessment];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [WMWoundMeasurement predicateForParentMeasurement:self.parentWoundMeasurement woundType:self.wound.woundType];
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
                           [NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:YES],
                           [NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES],
                           nil];
    }
    return sortDescriptors;
}

/**
 If this key path is not the same as that specified by the first sort descriptor in fetchRequest, they must generate the same relative orderings.
 For example, the first sort descriptor in fetchRequest might specify the key for a persistent property;
 sectionNameKeyPath might specify a key for a transient property derived from the persistent property.
 */
- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
	return (self.parentWoundMeasurement.childrenHaveSectionTitles ? @"sectionTitle":nil);
}

@end

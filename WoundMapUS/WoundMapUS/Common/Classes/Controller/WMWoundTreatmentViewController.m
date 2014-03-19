//
//  WMWoundTreatmentViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMWoundTreatmentViewController.h"
#import "WMWoundTreatmentGroupsViewController.h"
#import "WMWoundTreatmentSummaryViewController.h"
#import "WMWoundTreatmentGroupHistoryViewController.h"
#import "WMNoteViewController.h"
#import "WMWoundTreatment.h"
#import "WMWoundTreatmentValue.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentGroup+CoreText.h"
#import "WMWoundTreatmentIntEvent.h"
#import "WMInterventionStatus.h"
#import "WMInterventionEventType.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMDesignUtilities.h"
#import "PDFRenderer.h"
#import "UIView+Custom.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMWoundTreatmentViewController () <WoundTreatmentViewControllerDelegate, NoteViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectID *woundTreatmentGroupObjectID;
@property (strong, nonatomic) NSManagedObjectID *parentWoundTreatmentObjectID;
@property (strong, nonatomic) WMWoundTreatment *selectedWoundTreatment;
@property (strong, nonatomic) NSManagedObjectID *selectedWoundTreatmentObjectID;
@property (readonly, nonatomic) WMWoundTreatmentViewController *woundTreatmentViewController;
@property (readonly, nonatomic) WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController;
@property (readonly, nonatomic) WMWoundTreatmentGroupHistoryViewController *woundTreatmentGroupHistoryViewController;
@property (readonly, nonatomic) WMNoteViewController *noteViewController;

@end

@interface WMWoundTreatmentViewController (PrivateMethods)

- (void)navigateToChildrenWoundTreatments:(WMWoundTreatment *)woundTreatment;
- (void)reloadRowsForSelectedWoundTreatment:(WMWoundTreatment *)selectedWoundTreatment previousIndexPath:(NSIndexPath *)previousIndexPath;
- (void)navigateToNoteViewController:(WMWoundTreatment *)woundTreatment;

@end

@implementation WMWoundTreatmentViewController (PrivateMethods)

- (void)navigateToChildrenWoundTreatments:(WMWoundTreatment *)woundTreatment
{
    self.selectedWoundTreatment = woundTreatment;
    WMWoundTreatmentViewController *woundTreatmentViewController = self.woundTreatmentViewController;
    woundTreatmentViewController.parentWoundTreatment = woundTreatment;
    woundTreatmentViewController.woundTreatmentGroup = self.woundTreatmentGroup;
    [self clearOpenHeightsForAssessmentGroup:woundTreatment];
    [self.navigationController pushViewController:woundTreatmentViewController animated:YES];
}
- (void)reloadRowsForSelectedWoundTreatment:(WMWoundTreatment *)selectedWoundTreatment previousIndexPath:(NSIndexPath *)previousIndexPath
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:selectedWoundTreatment];
    if (![indexPath isEqual:previousIndexPath]) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, previousIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)navigateToNoteViewController:(WMWoundTreatment *)woundTreatment
{
    self.selectedWoundTreatment = woundTreatment;
    [self.navigationController pushViewController:self.noteViewController animated:YES];
}

@end

@implementation WMWoundTreatmentViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.parentWoundTreatment.hasChildrenWoundTreatments) {
        [self.managedObjectContext.undoManager beginUndoGrouping];
    }
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    if (nil != _woundTreatmentGroupObjectID && ![[_woundTreatmentGroup objectID] isTemporaryID]) {
        _woundTreatmentGroupObjectID = [_woundTreatmentGroup objectID];
        _woundTreatmentGroup = nil;
    }
    if (nil != _parentWoundTreatmentObjectID && ![[_parentWoundTreatment objectID] isTemporaryID]) {
        _parentWoundTreatmentObjectID = [_parentWoundTreatment objectID];
        _parentWoundTreatment = nil;
    }
    if (nil != _selectedWoundTreatmentObjectID && ![[_selectedWoundTreatment objectID] isTemporaryID]) {
        _selectedWoundTreatmentObjectID = [_selectedWoundTreatment objectID];
        _selectedWoundTreatment = nil;
    }
}

- (void)clearDataCache
{
    [super clearDataCache];
    _woundTreatmentGroup = nil;
    _woundTreatmentGroupObjectID = nil;
    _parentWoundTreatment = nil;
    _parentWoundTreatmentObjectID = nil;
    _selectedWoundTreatment = nil;
    _selectedWoundTreatmentObjectID = nil;
}

#pragma mark - Core

- (WMWoundTreatmentGroup *)woundTreatmentGroup
{
    if (nil == _woundTreatmentGroup) {
        WMWoundTreatmentGroup *woundTreatmentGroup = nil;
        if (nil == _woundTreatmentGroupObjectID) {
            woundTreatmentGroup = [WMWoundTreatmentGroup woundTreatmentGroupForWound:self.wound];
            self.didCreateGroup = YES;
            WMInterventionEvent *event = [woundTreatmentGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
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
        } else {
            woundTreatmentGroup = (WMWoundTreatmentGroup *)[self.managedObjectContext objectWithID:_woundTreatmentGroupObjectID];
        }
        self.woundTreatmentGroup = woundTreatmentGroup;
    }
    return _woundTreatmentGroup;
}

- (WMWoundTreatment *)parentWoundTreatment
{
    if (nil == _parentWoundTreatment && nil != _parentWoundTreatmentObjectID) {
        _parentWoundTreatment = (WMWoundTreatment *)[[self managedObjectContext] objectWithID:_parentWoundTreatmentObjectID];
    }
    return _parentWoundTreatment;
}

- (WMWoundTreatment *)selectedWoundTreatment
{
    if (nil == _selectedWoundTreatment && nil != _selectedWoundTreatmentObjectID) {
        _selectedWoundTreatment = (WMWoundTreatment *)[[self managedObjectContext] objectWithID:_selectedWoundTreatmentObjectID];
    }
    return _selectedWoundTreatment;
}

- (WMWoundTreatmentViewController *)woundTreatmentViewController
{
    WMWoundTreatmentViewController *woundTreatmentViewController = [[WMWoundTreatmentViewController alloc] initWithNibName:@"WMWoundTreatmentViewController" bundle:nil];
    woundTreatmentViewController.delegate = self;
    return woundTreatmentViewController;
}

- (WMWoundTreatmentSummaryViewController *)woundTreatmentSummaryViewController
{
    return [[WMWoundTreatmentSummaryViewController alloc] initWithNibName:@"WMWoundTreatmentSummaryViewController" bundle:nil];
}

- (WMWoundTreatmentGroupHistoryViewController *)woundTreatmentGroupHistoryViewController
{
    return [[WMWoundTreatmentGroupHistoryViewController alloc] initWithNibName:@"WMWoundTreatmentGroupHistoryViewController" bundle:nil];
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
    if ([WMWoundTreatmentGroup woundTreatmentGroupsHaveHistory:self.patient]) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showWoundTreatmentGroupHistoryAction:)]];
    }
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    NSString *title = (self.woundTreatmentGroup.status.isActive ? [NSString stringWithFormat:@"Current Status: %@", self.woundTreatmentGroup.status.title]:self.woundTreatmentGroup.status.title);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(updateStatusWoundTreatmentGroupAction:)];
    barButtonItem.enabled = self.woundTreatmentGroup.status.isActive;
    [items addObject:barButtonItem];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    if (self.woundTreatmentGroup.hasInterventionEvents) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showWoundTreatmentGroupEventsAction:)]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    if (nil != _parentWoundTreatment) {
        self.title = _parentWoundTreatment.title;
    } else {
        self.title = @"Wound Treatment";
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
    WMWoundTreatment *woundTreatment = (WMWoundTreatment *)assessmentGroup;
    WMWoundTreatmentValue *value = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:woundTreatment
                                                                                           create:NO
                                                                                            value:nil];
    if (nil == value) {
        return nil;
    }
    // else
    if (woundTreatment.groupValueTypeCode == GroupValueTypeCodeSelect) {
        return value;
    }
    // else
    return value.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    WMWoundTreatment *woundTreatment = (WMWoundTreatment *)assessmentGroup;
    WMWoundTreatment *parentWoundTreatment = woundTreatment.parentTreatment;
    BOOL createValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createValue = [value length] > 0;
    }
    if (createValue) {
        // unselect any other selection in category (section) unless in other section
        WMWoundTreatment * previousWoundTreatment = [self.woundTreatmentGroup woundTreatmentForParentWoundTreatment:parentWoundTreatment sectionTitle:woundTreatment.sectionTitle];
        if (nil != previousWoundTreatment && (nil == parentWoundTreatment || !parentWoundTreatment.allowMultipleChildSelection) && [previousWoundTreatment.sectionTitle isEqualToString:woundTreatment.sectionTitle]) {
            WMWoundTreatmentValue *previousWoundTreatmentValue = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:previousWoundTreatment
                                                                                                                         create:NO
                                                                                                                          value:nil];
            // remove previous (assumes parent does not allow multiple values)
            [self.woundTreatmentGroup removeValuesObject:previousWoundTreatmentValue];
            [self.managedObjectContext deleteObject:previousWoundTreatmentValue];
            // refresh the row
            NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:previousWoundTreatment];
            if (nil != indexPath) {
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
        }
    }
    WMWoundTreatmentValue *woundTreatmentValue = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:woundTreatment
                                                                                                         create:createValue
                                                                                                          value:nil];
    if (createValue) {
        woundTreatmentValue.value = value;
    } else if (nil != woundTreatmentValue) {
        [self.woundTreatmentGroup removeValuesObject:woundTreatmentValue];
        [self.managedObjectContext deleteObject:woundTreatmentValue];
    }
    // don't refresh if entering string value
    if (![value isKindOfClass:[NSString class]]) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:woundTreatment];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UIKeyboardType)keyboardTypeForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMWoundTreatment *woundTreatment = (WMWoundTreatment *)assessmentGroup;
    UIKeyboardType keyboardType = [woundTreatment.keyboardType intValue];
    if (self.isIPadIdiom && keyboardType == UIKeyboardTypeDecimalPad) {
        keyboardType = UIKeyboardTypeNumberPad;
    }
    return keyboardType;
}

#pragma mark - BaseViewController

#pragma mark - Actions

- (IBAction)showWoundTreatmentGroupHistoryAction:(id)sender
{
    [self.navigationController pushViewController:self.woundTreatmentGroupHistoryViewController animated:YES];
}

- (IBAction)updateStatusWoundTreatmentGroupAction:(id)sender
{
    [self presentInterventionStatusViewController];
}

- (IBAction)showWoundTreatmentGroupEventsAction:(id)sender
{
    [self presentInterventionEventViewController];
}

- (IBAction)saveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [super saveAction:sender];
    // create intervention events before super
    [self.woundTreatmentGroup createEditEventsForParticipant:self.appDelegate.participant];
    [self.delegate woundTreatmentViewControllerDidFinish:self];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.delegate woundTreatmentViewControllerDidCancel:self];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.woundTreatmentGroup;
}

- (void)interventionEventViewControllerDidCancel:(WMInterventionEventViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"Assessment Summary";
}

- (UIViewController *)summaryViewController
{
    WMWoundTreatmentSummaryViewController *woundTreatmentSummaryViewController = self.woundTreatmentSummaryViewController;
    woundTreatmentSummaryViewController.woundTreatmentGroup = self.woundTreatmentGroup;
    return woundTreatmentSummaryViewController;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return self.woundTreatmentGroup.status;
}

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.woundTreatmentGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.woundTreatmentGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                    title:nil
                                                                                valueFrom:nil
                                                                                  valueTo:nil
                                                                                     type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                                  managedObjectContext:self.managedObjectContext]
                                                                              participant:self.appDelegate.participant
                                                                                   create:YES
                                                                     managedObjectContext:self.managedObjectContext];
    DLog(@"Created WMWoundTreatmentInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - WMWoundTreatmentViewControllerDelegate

- (void)woundTreatmentViewController:(WMWoundTreatmentViewController *)viewController willDeleteWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
{
    if (_woundTreatmentGroup == woundTreatmentGroup) {
        _woundTreatmentGroup = nil;
    }
}

- (void)woundTreatmentViewControllerDidFinish:(WMWoundTreatmentViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    // clear ivars
    [viewController clearViewReferences];   // prevent refetch of WMWoundTreatmentGroup
    [viewController clearAllReferences];
}

- (void)woundTreatmentViewControllerDidCancel:(WMWoundTreatmentViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    // clear ivars and view
    [viewController clearViewReferences];   // prevent refetch of WMWoundTreatmentGroup
    [viewController clearAllReferences];
}

#pragma mark - AssessmentTableViewCellDelegate

- (CGFloat)updatedHeightForOpenState
{
    CGFloat height = 44.0;
    if (nil != self.selectedWoundTreatment) {
        id<AssessmentGroup> assessmentGroup = (id<AssessmentGroup>)self.selectedWoundTreatment;
        BOOL openFlag = [self isCellOpenForAssessmentGroup:assessmentGroup];
        if (openFlag && ![self isHeightRegisteredForOpenState:openFlag assessmentGroup:assessmentGroup]) {
            height = [self preferredHeightWithBaseHeight:[WMAssessmentTableViewCell defaultPreferredHeightForAssessmentGroup:assessmentGroup width:(UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.separatorInset).size.width)]
                                                   width:self.lastWidthForSummaryView
                                                openFlag:openFlag
                                         assessmentGroup:assessmentGroup];
        }
    }
    return height;
}

- (CGFloat)preferredHeightWithBaseHeight:(CGFloat)baseHeight width:(CGFloat)width openFlag:(BOOL)openFlag assessmentGroup:(id)assessmentGroup
{
    NSAssert1([assessmentGroup isKindOfClass:[WMWoundTreatment class]], @"Wrong class. Expected WMWoundTreatment, %@", assessmentGroup);
    WMWoundTreatment *woundTreatment = (WMWoundTreatment *)assessmentGroup;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    [self.woundTreatmentGroup appendToMutableAttributedString:mutableAttributedString
                                      forParentWoundTreatment:woundTreatment
                                                  indentLevel:0
                                             withBaseFontSize:9.0];
    // trim first \n
    if ([mutableAttributedString.string hasPrefix:@"\n"]) {
        [mutableAttributedString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    CGSize aSize = CGSizeMake(width, CGFLOAT_MAX);
    CGFloat height = ceilf([mutableAttributedString boundingRectWithSize:aSize
                                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                 context:nil].size.height);
    return (baseHeight + height);
}

- (void)drawSummaryViewForAssessmentGroup:(id)assessmentGroup inRect:(CGRect)rect
{
    NSAssert1([assessmentGroup isKindOfClass:[WMWoundTreatment class]], @"Wrong class. Expected WMWoundTreatment, %@", assessmentGroup);
    NSAttributedString *attributedString = [self attributedStringForSummary:assessmentGroup];
    NSStringDrawingContext *stringDrawingContext = [[NSStringDrawingContext alloc] init];
    [attributedString drawWithRect:rect
                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                           context:stringDrawingContext];
    DLog(@"stringDrawingContext: %@", stringDrawingContext);
}

- (NSAttributedString *)attributedStringForSummary:(id)assessmentGroup
{
    WMWoundTreatment *woundTreatment = (WMWoundTreatment *)assessmentGroup;
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    [self.woundTreatmentGroup appendToMutableAttributedString:mutableAttributedString
                                      forParentWoundTreatment:woundTreatment
                                                  indentLevel:0
                                             withBaseFontSize:9.0];
    // trim first \n
    if ([mutableAttributedString.string hasPrefix:@"\n"]) {
        [mutableAttributedString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    return mutableAttributedString;
}

#pragma mark - NoteViewControllerDelegate

- (NSString *)note
{
    WMWoundTreatmentValue *value = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:self.selectedWoundTreatment
                                                                                           create:NO
                                                                                            value:nil];
    return value.value;
}

- (NSString *)label
{
    return self.selectedWoundTreatment.placeHolder;
}

- (void)noteViewController:(WMNoteViewController *)viewController didUpdateNote:(NSString *)note
{
    WMWoundTreatmentValue *value = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:self.selectedWoundTreatment
                                                                                           create:YES
                                                                                            value:nil];
    value.value = note;
    [self.navigationController popViewControllerAnimated:YES];
    // reload the section if only one selection allowed
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.fetchedResultsController indexPathForObject:self.selectedWoundTreatment]] withRowAnimation:UITableViewRowAnimationFade];
    self.selectedWoundTreatment = nil;
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
    WMWoundTreatment *woundTreatment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // navigate
    if (woundTreatment.hasChildrenWoundTreatments) {
        [self navigateToChildrenWoundTreatments:woundTreatment];
        return;
    }
    // else
    if (woundTreatment.groupValueTypeCode == GroupValueTypeCodeNavigateToNote) {
        [self navigateToNoteViewController:woundTreatment];
        return;
    }
    // else check if there is a control in the cell
    BOOL refreshRow = YES;
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
    if (!refreshRow) {
        return;
    }
    // else no control, so we may need to remove and add values
    NSIndexPath *previousIndexPath = nil;
    WMWoundTreatmentValue *woundTreatmentValue = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:woundTreatment
                                                                                                         create:NO
                                                                                                          value:nil];
    if (nil == woundTreatmentValue) {
        // acquire possible previous value - if in another section, don't delete
        WMWoundTreatment * previousWoundTreatment = [self.woundTreatmentGroup woundTreatmentForParentWoundTreatment:self.parentWoundTreatment sectionTitle:woundTreatment.sectionTitle];
        WMWoundTreatmentValue *previousWoundTreatmentValue = nil;
        if (nil != previousWoundTreatment && (nil == self.parentWoundTreatment || !self.parentWoundTreatment.allowMultipleChildSelection) && [previousWoundTreatment.sectionTitle isEqualToString:woundTreatment.sectionTitle]) {
            previousWoundTreatmentValue = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:previousWoundTreatment
                                                                                                  create:NO
                                                                                                   value:nil];
            previousIndexPath = [self.fetchedResultsController indexPathForObject:previousWoundTreatment];
        }
        // else go ahead and select
        woundTreatmentValue = [self.woundTreatmentGroup woundTreatmentValueForWoundTreatment:woundTreatment
                                                                                      create:YES
                                                                                       value:nil];
        [self.woundTreatmentGroup addValuesObject:woundTreatmentValue];
        if (nil != previousWoundTreatmentValue) {
            // remove previous (assumes parent does not allow multiple values)
            [self.woundTreatmentGroup removeValuesObject:previousWoundTreatmentValue];
            [self.managedObjectContext deleteObject:previousWoundTreatmentValue];
        }
    } else {
        // existed, so selecting will remove value
        [self.woundTreatmentGroup removeValuesObject:woundTreatmentValue];
        [self.managedObjectContext deleteObject:woundTreatmentValue];
    }
    [self reloadRowsForSelectedWoundTreatment:woundTreatment previousIndexPath:previousIndexPath];
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

- (NSInteger)selectionCountForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    NSInteger count = 0;
    WMWoundTreatment *woundTreatment = (WMWoundTreatment *)assessmentGroup;
    if ([self.woundTreatmentGroup hasWoundTreatmentValuesForWoundTreatmentAndChildren:woundTreatment]) {
        if (woundTreatment.allowMultipleChildSelection) {
            // get the count
            count = [self.woundTreatmentGroup valuesCountForWoundTreatment:woundTreatment];
            count = MIN(count, 10);
        } else {
            count = 1;
        }
    }
    // double back
    if (woundTreatment.skipSelectionIcon) {
        count = NSNotFound;
    }
    return count;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMWoundTreatment");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundTreatment];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [WMWoundTreatment predicateForParentTreatment:self.parentWoundTreatment woundType:self.wound.woundType];
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
	return (self.parentWoundTreatment.childrenHaveSectionTitles ? @"sectionTitle":nil);
}

@end

//
//  WMBuildGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBuildGroupViewController.h"
#import "WMDefinitionTableViewCell.h"
#import "WMDefinition.h"
#import "PDFRenderer.h"
#import "WMDesignUtilities.h"
#import "UIView+Custom.h"
#import "WMUtilities.h"

NSString *const kGroupOpenClosedKey = @"GroupOpenClosedKey";
NSString *const kGroupClosedHeightKey = @"GroupClosedHeightKey";
NSString *const kGroupOpenHeightKey = @"GroupOpenHeightKey";

@interface WMBuildGroupViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *previousNextSegmentedControl;
@property (readonly, nonatomic) WMInterventionStatusViewController *interventionStatusViewController;
@property (readonly, nonatomic) WMInterventionEventViewController *interventionEventViewController;
@property (strong, nonatomic) WMDefinition *selectedDefinition;
@property (strong, nonatomic) NSMutableDictionary *assessmentGroup2OpenMap;

- (void)configureDefinitionCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)scrollSelectedDefinitionIntoView:(NSIndexPath *)indexPath;

@end

@implementation WMBuildGroupViewController

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalInPopover = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[WMAssessmentTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.searchDisplayController.searchResultsTableView registerClass:[WMDefinitionTableViewCell class] forCellReuseIdentifier:@"DefinitionCell"];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIForDataChange];
    // hide the search views in tableView tableHeaderView
    if (CGPointEqualToPoint(CGPointZero, self.tableView.contentOffset)) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // update model before save in super.viewWillDissappear:
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
    // reset state
    self.didCreateGroup = NO;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// clear any strong references to views
- (void)clearViewReferences
{
    _searchBar = nil;
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    [super clearViewReferences];
}

- (void)clearDataCache
{
    [super clearDataCache];
    _selectedDefinition = nil;
    _assessmentGroup2OpenMap = nil;
    _indexPathForDelayedFirstResponder = nil;
}

#pragma mark - Actions

// inline switch for YES/NO
- (IBAction)switchValueChangedAction:(id)sender
{
    UISwitch *aSwitch = (UISwitch *)sender;
    UITableViewCell *cell = [self cellForView:aSwitch];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self updateAssessmentGroup:assessmentGroup withValue:(aSwitch.isOn ? @"YES":@"NO")];
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
}

- (IBAction)segmentedControlValueChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    UITableViewCell *cell = [self cellForView:segmentedControl];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    id value = (UISegmentedControlNoSegment == segmentedControl.selectedSegmentIndex ? nil:[NSString stringWithFormat:@"%ld", (long)segmentedControl.selectedSegmentIndex]);
    [self updateAssessmentGroup:assessmentGroup withValue:value];
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (IBAction)optionSegmentedControlValueChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    UITableViewCell *cell = [self cellForView:segmentedControl];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    id value = (UISegmentedControlNoSegment == segmentedControl.selectedSegmentIndex ? nil:[NSString stringWithFormat:@"%ld", (long)segmentedControl.selectedSegmentIndex]);
    [self updateAssessmentGroup:assessmentGroup withValue:value];
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
    //    [self.tableView beginUpdates];
    //    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //    [self.tableView endUpdates];
}

- (IBAction)sliderValueChangedAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    UITableViewCell *cell = [self cellForView:slider];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger value = slider.value;
    NSString *valueString = [NSString stringWithFormat:@"%ld", (long)value];
    // update UI
    UILabel *label = [self valueLabelForTableViewCell:cell];
    label.text = valueString;
    // update model
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self updateAssessmentGroup:assessmentGroup withValue:valueString];
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
}

- (IBAction)sliderPercentValueChangedAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    WMAssessmentTableViewCell *cell = (WMAssessmentTableViewCell *)[self cellForView:slider];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (nil == indexPath) {
        return;
    }
    // else
    NSInteger value = slider.value;
    NSString *valueString = [NSString stringWithFormat:@"%ld", (long)value];
    // update UI
    UITextField *textField = [self textFieldForTableViewCell:cell];
    textField.text = valueString;
    // update model
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self updateAssessmentGroup:assessmentGroup withValue:valueString];
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
}

- (IBAction)previousNextAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = nil;
    UIResponder *responder = nil;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
            // previous
            responder = [self previousTextFieldResponder];
            if (nil == responder) {
                indexPath = [visibleIndexPaths objectAtIndex:0];
            } else {
                UITableViewCell *cell = [self cellForView:(UIView *)responder];
                indexPath = [self.tableView indexPathForCell:cell];
            }
            break;
        }
        case 1: {
            // next
            responder = [self nextTextFieldResponder];
            if (nil == responder) {
                indexPath = [visibleIndexPaths lastObject];
            } else {
                UITableViewCell *cell = [self cellForView:(UIView *)responder];
                indexPath = [self.tableView indexPathForCell:cell];
            }
            break;
        }
    }
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [responder becomeFirstResponder];
}

- (IBAction)dismissInputViewAction:(id)sender
{
    self.indexPathForDelayedFirstResponder = nil;
    [self.view endEditing:YES];
}

- (IBAction)initiateSearchAction:(id)sender
{
    [self updateUIForSearch];
}

// delay to avoid popping two view controllers before animation finishes
- (IBAction)delayedCancelAction:(id)sender
{
    [self performSelector:@selector(cancelAction:) withObject:sender afterDelay:0.0];
}

// subclass should override
- (IBAction)cancelAction:(id)sender
{
    self.willCancelFlag = YES;
    [self.view endEditing:YES];
    // do not managedObjectContext rollback - we may have a wound that will be deleted
}

// subclass should override
- (IBAction)saveAction:(id)sender
{
    self.willCancelFlag = NO;
    // get any values in text fields
    [self.view endEditing:YES];
}

#pragma mark - Open/Closed Cell

- (PDFRenderer *)renderer
{
    if (nil == _renderer) {
        _renderer = [[PDFRenderer alloc] init];
        _renderer.defaultFontSize = 17.0;
    }
    return _renderer;
}

- (NSMutableDictionary *)assessmentGroup2OpenMap
{
    if (nil == _assessmentGroup2OpenMap) {
        _assessmentGroup2OpenMap = [[NSMutableDictionary alloc] initWithCapacity:128];
    }
    return _assessmentGroup2OpenMap;
}

- (NSManagedObjectID *)objectIDForAssessmentGroup:(id)assessmentGroup
{
    NSManagedObjectID *objectID = [assessmentGroup objectID];
    if ([objectID isTemporaryID]) {
        NSError *error = nil;
        BOOL success = [[assessmentGroup managedObjectContext] obtainPermanentIDsForObjects:[NSArray arrayWithObject:assessmentGroup] error:&error];
        if (!success) {
            [WMUtilities logError:error];
        }
        objectID = [assessmentGroup objectID];
    }
    return objectID;
}

- (NSMutableDictionary *)openHeightMapForAssessmentGroup:(id)assessmentGroup
{
    NSManagedObjectID *objectID = [self objectIDForAssessmentGroup:assessmentGroup];
    NSMutableDictionary *dictionary = [self.assessmentGroup2OpenMap objectForKey:objectID];
    if (nil == dictionary) {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
        [self.assessmentGroup2OpenMap setObject:dictionary forKey:objectID];
    }
    return dictionary;
}

- (BOOL)isCellOpenForAssessmentGroup:(id)assessmentGroup
{
    return [[[self openHeightMapForAssessmentGroup:assessmentGroup] objectForKey:kGroupOpenClosedKey] boolValue];
}

- (void)updateCellOpenState:(BOOL)openFlag forAssessmentGroup:(id)assessmentGroup
{
    [[self openHeightMapForAssessmentGroup:assessmentGroup] setObject:[NSNumber numberWithBool:openFlag] forKey:kGroupOpenClosedKey];
}

- (CGFloat)cellHeightForAssessmentGroup:(id)assessmentGroup
{
    CGFloat height = 44.0;
    NSMutableDictionary *dictionary = [self openHeightMapForAssessmentGroup:assessmentGroup];
    if ([self isCellOpenForAssessmentGroup:assessmentGroup]) {
        height = [[dictionary objectForKey:kGroupOpenHeightKey] floatValue];
    } else {
        height = [[dictionary objectForKey:kGroupClosedHeightKey] floatValue];
    }
    return height;
}

- (NSMutableDictionary *)registerOpenState:(BOOL)openFlag withHeight:(CGFloat)height forAssessmentGroup:(id)assessmentGroup
{
    NSMutableDictionary *dictionary = [self openHeightMapForAssessmentGroup:assessmentGroup];
    [dictionary setObject:[NSNumber numberWithBool:openFlag] forKey:kGroupOpenClosedKey];
    if (openFlag) {
        [dictionary setObject:[NSNumber numberWithFloat:height] forKey:kGroupOpenHeightKey];
    } else {
        [dictionary setObject:[NSNumber numberWithFloat:height] forKey:kGroupClosedHeightKey];
    }
    return dictionary;
}

- (BOOL)isHeightRegisteredForOpenState:(BOOL)openFlag assessmentGroup:(id)assessmentGroup
{
    NSMutableDictionary *dictionary = [self openHeightMapForAssessmentGroup:assessmentGroup];
    if (openFlag) {
        return nil != [dictionary objectForKey:kGroupOpenHeightKey];
    }
    // else
    return nil != [dictionary objectForKey:kGroupClosedHeightKey];
}

// subclasses should override
- (CGFloat)preferredHeightWithBaseHeight:(CGFloat)baseHeight width:(CGFloat)width openFlag:(BOOL)openFlag assessmentGroup:(id)assessmentGroup
{
    return baseHeight;
}

- (void)clearOpenHeightsForAssessmentGroup:(id)assessmentGroup
{
    NSMutableDictionary *dictionary = [self openHeightMapForAssessmentGroup:assessmentGroup];
    [dictionary removeObjectForKey:kGroupOpenHeightKey];
}

- (void)dumpOpenCacheForAssessmentGroup:(id)assessmentGroup
{
    [self.assessmentGroup2OpenMap removeObjectForKey:[self objectIDForAssessmentGroup:assessmentGroup]];
}

- (CGFloat)updatedHeightForOpenState
{
    return 0.0;
}

#pragma mark - Core

- (BOOL)shouldShowToolbar
{
    return NO;
}

- (void)updateToolbarItems
{
}

- (void)updateUIForDataChange
{
    [self updateToolbarItems];
    if (self.managedObjectContext.hasChanges) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(delayedCancelAction:)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                 target:self
                                                                                                 action:@selector(saveAction:)],
                                                   nil];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                 target:self
                                                                                                 action:@selector(saveAction:)],
                                                   nil];
    }
}

- (void)updateUIForSearch
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = nil;
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (NSString *)cellIdentifierForValueTypeCode:(GroupValueTypeCode)valueTypeCode
{
    NSString *cellIdentifier = @"Cell";
    switch (valueTypeCode) {
        case GroupValueTypeCodeSelect: {
            cellIdentifier = @"SelectCell";
            break;
        }
        case GroupValueTypeCodeValue1Select: {
            cellIdentifier = @"Value1Cell";
            break;
        }
        case GroupValueTypeCodeInlineTextField: {
            cellIdentifier = @"KeyValueCell";
            break;
        }
        case GroupValueTypeCodeInlineOptions: {
            cellIdentifier = @"InlineOptionsCell";
            break;
        }
        case GroupValueTypeCodeInlineNoImageOptions: {
            cellIdentifier = @"SegmentedOptionsCell";
            break;
        }
        case GroupValueTypeCodeUndermineTunnel:
        case GroupValueTypeCodeDefaultNavigateToOptions: {
            cellIdentifier = @"DefaultNavigationCell";
            break;
        }
        case GroupValueTypeCodeValue1NavigateToAmounts:
        case GroupValueTypeCodeValue1NavigateToOdors:
        case GroupValueTypeCodeValue1NavigateToOptions: {
            cellIdentifier = @"Value1NavigationCell";
            break;
        }
        case GroupValueTypeCodeSubtitleNavigateToOptions: {
            cellIdentifier = @"SubtitleNavigationCell";
            break;
        }
        case GroupValueTypeCodeInlineSwitch: {
            cellIdentifier = @"SwitchTableViewCell";
            break;
        }
        case GroupValueTypeCodeNoImageInlineSwitch: {
            cellIdentifier = @"SwitchCellNoImage";
            break;
        }
        case GroupValueTypeCodeInlineSlider: {
            cellIdentifier = @"SliderCell";
            break;
        }
        case GroupValueTypeCodeInlineSliderPercentage: {
            cellIdentifier = @"SliderValuePercentCell";
            break;
        }
        case GroupValueTypeCodeInlineExtendsTextField: {
            cellIdentifier = @"ExtendsOutCell";
            break;
        }
        case GroupValueTypeCodeNavigateToNote: {
            cellIdentifier = @"NavigateToNoteCell";
            break;
        }
        case GroupValueTypeCodeQuestionWithOptions: {
            cellIdentifier = @"GroupValueTypeCodeQuestionWithOptions";
            break;
        }
        case GroupValueTypeCodeQuestionNavigateOptions: {
            cellIdentifier = @"GroupValueTypeCodeQuestionNavigateOptions";
            break;
        }
    }
    return cellIdentifier;
}

- (BOOL)shouldShowSelectionImageForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    GroupValueTypeCode groupValueTypeCode = assessmentGroup.groupValueTypeCode;
    BOOL result = YES;
    switch (groupValueTypeCode) {
        case GroupValueTypeCodeSelect: {
            break;
        }
        case GroupValueTypeCodeValue1Select: {
            break;
        }
        case GroupValueTypeCodeInlineTextField: {
            break;
        }
        case GroupValueTypeCodeInlineOptions: {
            break;
        }
        case GroupValueTypeCodeInlineNoImageOptions: {
            result = NO;
            break;
        }
        case GroupValueTypeCodeDefaultNavigateToOptions: {
            break;
        }
        case GroupValueTypeCodeValue1NavigateToOptions: {
            break;
        }
        case GroupValueTypeCodeSubtitleNavigateToOptions: {
            break;
        }
        case GroupValueTypeCodeInlineSwitch: {
            result = NO;
            break;
        }
        case GroupValueTypeCodeNoImageInlineSwitch: {
            result = NO;
            break;
        }
        case GroupValueTypeCodeInlineSlider: {
            result = NO;
            break;
        }
        case GroupValueTypeCodeInlineSliderPercentage: {
            result = NO;
            break;
        }
        case GroupValueTypeCodeInlineExtendsTextField: {
            break;
        }
        case GroupValueTypeCodeValue1NavigateToAmounts: {
            break;
        }
        case GroupValueTypeCodeValue1NavigateToOdors: {
            break;
        }
        case GroupValueTypeCodeUndermineTunnel: {
            break;
        }
        case GroupValueTypeCodeNavigateToNote: {
            break;
        }
        case GroupValueTypeCodeQuestionWithOptions: {
            result = NO;
            break;
        }
        case GroupValueTypeCodeQuestionNavigateOptions: {
            result = YES;
            break;
        }
    }
    return result;
}

- (NSInteger)selectionCountForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    NSInteger count = 0;
    if ([self shouldShowSelectionImageForAssessmentGroup:assessmentGroup]) {
        if (nil != [self valueForAssessmentGroup:assessmentGroup]) {
            // value exists
            count = 1;
        }
    } else {
        count = NSNotFound;
    }
    return count;
}

- (UIResponder *)nextTextFieldResponder
{
    UIView *responder = [self.tableView findFirstResponder];
    UITableViewCell *cell = [self cellForView:responder];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    // move forward through table
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row + 1;
    NSInteger sectionCount = [self.tableView numberOfSections];
    while (section < sectionCount) {
        NSInteger rowCount = [self.tableView numberOfRowsInSection:section];
        while (row < rowCount) {
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            // cell may be nil if not yet in tableView queue
            if (nil == cell) {
                // look for a text field based on the model
                id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
                if (assessmentGroup.groupValueTypeCode == GroupValueTypeCodeInlineTextField) {
                    // scroll into view, since the textField does not exist yet
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    // since the textField does not exist yet, we need to wait until it exists to make it first responder
                    self.indexPathForDelayedFirstResponder = indexPath;
                    return nil;
                }
            } else {
                UIResponder *aResponder = [self possibleFirstResponderInCell:cell];
                if (nil != aResponder) {
                    [cell setNeedsDisplay];
                    return aResponder;
                }
            }
            // else
            ++row;
        }
        ++section;
        row = 0;
    }
    // else
    return nil;
}

- (UIResponder *)previousTextFieldResponder
{
    UIView *responder = [self.tableView findFirstResponder];
    UITableViewCell *cell = [self cellForView:responder];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    // move backward through table
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row - 1;
    while (YES) {
        while (row >= 0) {
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            UIResponder *aResponder = [self possibleFirstResponderInCell:cell];
            if (nil != aResponder) {
                [cell setNeedsDisplay];
                return aResponder;
            }
            // else
            --row;
        }
        --section;
        if (section < 0) {
            break;
        }
        // else
        row = [self.tableView numberOfRowsInSection:section] - 1;
    }
    // else
    return nil;
}

- (UIResponder *)possibleFirstResponderInCell:(UITableViewCell *)cell
{
    NSArray *subviews = cell.contentView.subviews;
    if ([cell isKindOfClass:[WMAssessmentTableViewCell class]]) {
        WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
        subviews = myCell.customContentView.subviews;
    }
    for (UIResponder *responder in subviews) {
        if ([responder isKindOfClass:[UIResponder class]] && responder.canBecomeFirstResponder) {
            return responder;
        }
    }
    // else
    return nil;
}

- (UIControl *)controlInCell:(UITableViewCell *)cell
{
    for (id subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UIControl class]]) {
            return (UIControl *)subview;
        }
    }
    // else
    return nil;
}

- (UITextField *)textFieldForTableViewCell:(UITableViewCell *)cell
{
    WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
    return myCell.valueTextField;
}

- (UILabel *)valueLabelForTableViewCell:(UITableViewCell *)cell
{
    WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
    return myCell.valueLabel;
}

- (UISegmentedControl *)segmentedControlForTableViewCell:(UITableViewCell *)cell
{
    WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
    return myCell.valueSegmentedControl;
}

- (UISwitch *)switchForTableViewCell:(UITableViewCell *)cell
{
    WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
    return myCell.valueSwitch;
}

- (UISlider *)sliderForTableViewCell:(UITableViewCell *)cell
{
    WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
    return myCell.valueSlider;
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    return assessmentGroup.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    assessmentGroup.value = value;
}

- (UIKeyboardType)keyboardTypeForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    return UIKeyboardTypeDefault;
}

- (WMInterventionStatusViewController *)interventionStatusViewController
{
    WMInterventionStatusViewController *interventionStatusViewController = [[WMInterventionStatusViewController alloc] initWithNibName:@"WMInterventionStatusViewController" bundle:nil];
    interventionStatusViewController.delegate = self;
    return interventionStatusViewController;
}

- (WMInterventionEventViewController *)interventionEventViewController
{
    WMInterventionEventViewController *interventionEventViewController = [[WMInterventionEventViewController alloc] initWithNibName:@"WMInterventionEventViewController" bundle:nil];
    interventionEventViewController.delegate = self;
    return interventionEventViewController;
}

- (void)presentInterventionStatusViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.interventionStatusViewController];
    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)presentInterventionEventViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.interventionEventViewController];
    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

#pragma mark - Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - BaseViewController

- (void)nilFetchedResultsController
{
    _selectedDefinition = nil;
    [super nilFetchedResultsController];
}

#pragma mark - AssessmentTableViewCellDelegate

- (UIToolbar *)inputAccessoryToolbar
{
    return self.inputAccessoryView;
}

- (id)currentGroup
{
    return nil;
}

- (BOOL)isIndexPathForDelayedFirstResponder:(WMAssessmentTableViewCell *)assessmentTableViewCell
{
    return [[self.tableView indexPathForCell:assessmentTableViewCell] isEqual:self.indexPathForDelayedFirstResponder];
}

- (void)handleWillOpenOrClose:(BOOL)openFlag forCell:(WMAssessmentTableViewCell *)assessmentTableViewCell width:(CGFloat)width
{
    _lastWidthForSummaryView = width;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:assessmentTableViewCell];
    [self.tableView beginUpdates];
    if (![self isHeightRegisteredForOpenState:openFlag assessmentGroup:assessmentTableViewCell.assessmentGroup]) {
        CGFloat height = [self preferredHeightWithBaseHeight:assessmentTableViewCell.preferredHeight width:width openFlag:openFlag assessmentGroup:assessmentTableViewCell.assessmentGroup];
        [self registerOpenState:openFlag withHeight:height forAssessmentGroup:assessmentTableViewCell.assessmentGroup];
    } else {
        [self openHeightMapForAssessmentGroup:assessmentTableViewCell.assessmentGroup];
    }
    [self updateCellOpenState:openFlag forAssessmentGroup:assessmentTableViewCell.assessmentGroup];
    assessmentTableViewCell.openFlag = openFlag;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

// subclasses should override
- (void)drawSummaryViewForAssessmentGroup:(id)assessmentGroup inRect:(CGRect)rect
{
}

// subclasses should override
- (NSAttributedString *)attributedStringForSummary:(id)assessmentGroup
{
    return nil;
}


#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"View Summary";
}

- (UIViewController *)summaryViewController
{
    return nil;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return nil;
}

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    [self dismissViewControllerAnimated:YES completion:^{
        [viewController clearAllReferences];
    }];
}

- (void)interventionStatusViewControllerDidCancel:(WMInterventionStatusViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [viewController clearAllReferences];
    }];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return nil;
}

- (void)interventionEventViewControllerDidCancel:(WMInterventionEventViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
    return YES;
}

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([indexPath isEqual:self.indexPathForDelayedFirstResponder]) {
        self.indexPathForDelayedFirstResponder = nil;
        return NO;
    }
    // else
    return YES;
}

// called when 'return' key pressed. return NO to ignore
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	UITableViewCell *cell = [self cellForView:textField];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (nil == indexPath || self.willCancelFlag) {
        return;
    }
    // else
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self updateAssessmentGroup:assessmentGroup withValue:textField.text];
    // update slider
    if (assessmentGroup.groupValueTypeCode == GroupValueTypeCodeInlineSliderPercentage) {
        WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
        myCell.valueSlider.value = [textField.text floatValue];
    }
    // refresh this cell
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - UISearchBarDelegate

// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (nil == self.searchDisplayController) {
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        searchDisplayController.searchResultsDelegate = self;
    }
    [self nilFetchedResultsController];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self nilFetchedResultsController];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self nilFetchedResultsController];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self nilFetchedResultsController];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if (!self.navigationController.toolbarHidden) {
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.navigationController setToolbarHidden:!self.shouldShowToolbar animated:NO];
}

- (void)searchDisplayController:(UISearchDisplayController *)viewController willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[WMDefinitionTableViewCell class] forCellReuseIdentifier:@"DefinitionCell"];
    self.tableView.hidden = YES;
}

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)viewController shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString length] == 0) {
        return NO;
    }
    // else
    [self nilFetchedResultsController];
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)viewController shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    if ([viewController.searchBar.text length] == 0) {
        return NO;
    }
    // else
    [self nilFetchedResultsController];
	return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    self.tableView.hidden = NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)viewController didHideSearchResultsTableView:(UITableView *)tableView
{
    [self nilFetchedResultsController];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (self.isSearchActive) {
        if (nil != _selectedDefinition && [indexPath isEqual:[self.fetchedResultsController indexPathForObject:_selectedDefinition]]) {
            height = [WMDefinitionTableViewCell heightThatFitsDefinition:_selectedDefinition
                                                       fullDescription:YES
                                                                 width:CGRectGetWidth(UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.separatorInset))];
        }
        return ceilf(height);
    }
    // else
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    height = [self cellHeightForAssessmentGroup:assessmentGroup];
    if (0.0 == height) {
        BOOL openFlag = [self isCellOpenForAssessmentGroup:assessmentGroup];
        if (openFlag) {
            height = [self updatedHeightForOpenState];
        } else {
            height = [WMAssessmentTableViewCell defaultPreferredHeightForAssessmentGroup:assessmentGroup width:(UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.separatorInset).size.width)];
        }
        [self registerOpenState:openFlag withHeight:height forAssessmentGroup:assessmentGroup];
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchActive) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // get the current selected indexPath
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:4];
        if (nil != _selectedDefinition) {
            NSIndexPath *currentIndexPath = [self.fetchedResultsController indexPathForObject:_selectedDefinition];
            if (![indexPath isEqual:currentIndexPath]) {
                [indexPaths addObject:[self.fetchedResultsController indexPathForObject:_selectedDefinition]];
            }
        }
        self.selectedDefinition = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [indexPaths addObject:indexPath];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self performSelector:@selector(scrollSelectedDefinitionIntoView:) withObject:indexPath afterDelay:0.0];
        return;
    } else {
        // if first responder not in the indexPath,
        UIView *firstResponder = [self.view findFirstResponder];
        if (nil != firstResponder) {
            UITableViewCell *cell = [self cellForView:firstResponder];
            if (nil != cell) {
                NSIndexPath *firstResponderIndexPath = [self.tableView indexPathForCell:cell];
                if (![firstResponderIndexPath isEqual:indexPath]) {
                    [firstResponder resignFirstResponder];
                }
            }
        }
    }
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cellIdentifier = @"DefinitionCell";
    } else {
        cellIdentifier = @"Cell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self configureDefinitionCell:cell atIndexPath:indexPath];
    } else if (!self.isSearchActive) {
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)configureDefinitionCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMDefinitionTableViewCell *myCell = (WMDefinitionTableViewCell *)cell;
    WMDefinition *definition = [self.fetchedResultsController objectAtIndexPath:indexPath];
    myCell.drawFullDescription = (definition == _selectedDefinition);
    myCell.definition = definition;
}

- (void)scrollSelectedDefinitionIntoView:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.activeTableView cellForRowAtIndexPath:indexPath];
    CGRect cellFrame = cell.frame;
    CGRect intersection = CGRectIntersection(self.activeTableView.bounds, cellFrame);
    CGFloat deltaY = CGRectGetMinY(cellFrame) - CGRectGetMinY(intersection);
    if (0.0 == deltaY) {
        deltaY = CGRectGetMaxY(cellFrame) - CGRectGetMaxY(intersection);
    }
    if (0.0 == deltaY) {
        return;
    }
    // else
    CGPoint contentOffset = self.activeTableView.contentOffset;
    contentOffset.y += deltaY;
    [self.activeTableView setContentOffset:contentOffset animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // make sure the fetchedResultsController has not fetched definitions
    if ([self.fetchedResultsController.fetchRequest.entityName isEqualToString:@"WCDefinition"]) {
        // let it go
        DLog(@"Search has become active, but we got a call to configure AssessmentGroup cell. Continuing on...");
        return;
    }
    // else
    id<AssessmentGroup> assessmentGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
    myCell.delegate = self;
    [myCell configureForAssessmentGroup:assessmentGroup
                         selectionCount:[self selectionCountForAssessmentGroup:assessmentGroup]
                               openFlag:[self isCellOpenForAssessmentGroup:assessmentGroup]];
}

@end

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
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMWoundTreatment.h"
#import "WMWoundTreatmentValue.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentGroup+CoreText.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMInterventionEventType.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMDesignUtilities.h"
#import "PDFRenderer.h"
#import "UIView+Custom.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMWoundTreatmentViewController () <WoundTreatmentViewControllerDelegate, NoteViewControllerDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (strong, nonatomic) WMWoundTreatment *selectedWoundTreatment;
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
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, previousIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
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
    if (nil == _parentWoundTreatment && nil == _woundTreatmentGroup) {
        _woundTreatmentGroup = [WMWoundTreatmentGroup activeWoundTreatmentGroupForWound:self.wound];
    }
    if (_parentWoundTreatment || _woundTreatmentGroup) {
        // we want to support cancel, so make sure we have an undoManager
        if (nil == self.managedObjectContext.undoManager) {
            self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
            _removeUndoManagerWhenDone = YES;
        }
        [self.managedObjectContext.undoManager beginUndoGrouping];
    }
}

#pragma mark - Memory

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
            if (!weakSelf.didCreateGroup) {
                [weakSelf.tableView reloadData];
            }
        };
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

- (void)clearDataCache
{
    [super clearDataCache];
    _woundTreatmentGroup = nil;
    _parentWoundTreatment = nil;
    _selectedWoundTreatment = nil;
}

#pragma mark - Core

- (WMWoundTreatmentGroup *)woundTreatmentGroup
{
    if (nil == _woundTreatmentGroup) {
        _woundTreatmentGroup = [WMWoundTreatmentGroup woundTreatmentGroupForWound:self.wound];
        self.didCreateGroup = YES;
        // create on back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        WMWound *wound = self.wound;
        __block NSInteger counter = 0;
        __weak __typeof(&*self)weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                --counter;
                if (counter == 0) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                }
            }
        };
        [ff createObj:_woundTreatmentGroup atUri:[NSString stringWithFormat:@"/%@", [WMWoundTreatmentGroup entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                ++counter;
                [ff grabBagAddItemAtFfUrl:_woundTreatmentGroup.ffUrl
                             toObjAtFfUrl:wound.ffUrl
                              grabBagName:WMWoundRelationships.treatmentGroups
                               onComplete:completionHandler];
            }
        }];
        
        WMInterventionEvent *event = [_woundTreatmentGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
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
    return _woundTreatmentGroup;
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
    if ([WMWoundTreatmentGroup woundTreatmentGroupsHaveHistory:self.wound]) {
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

- (void)deleteWoundTreatmentValue:(WMWoundTreatmentValue *)woundTreatmentValue
{
    if (_woundTreatmentGroup.ffUrl) {
        if (woundTreatmentValue.ffUrl) {
            FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                }
            };
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            [ff grabBagRemoveItemAtFfUrl:woundTreatmentValue.ffUrl fromObjAtFfUrl:_woundTreatmentGroup.ffUrl grabBagName:WMWoundTreatmentGroupRelationships.values onComplete:completionHandler];
            [ff deleteObj:woundTreatmentValue onComplete:completionHandler];
        }
    }
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
            // update back end
            [self deleteWoundTreatmentValue:previousWoundTreatmentValue];
            // refresh the row
            NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:previousWoundTreatment];
            if (nil != indexPath) {
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
        // update back end
        [self deleteWoundTreatmentValue:woundTreatmentValue];
    }
    // don't refresh if entering string value
    if (![value isKindOfClass:[NSString class]]) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:woundTreatment];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
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
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        managedObjectContext.undoManager = nil;
    }
    [super saveAction:sender];
    // create intervention events after super
    [self.woundTreatmentGroup createEditEventsForParticipant:self.appDelegate.participant];
    // wait for back end calls to complete
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        WM_ASSERT_MAIN_THREAD;
        if (nil == _parentWoundTreatment) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.delegate woundTreatmentViewControllerDidFinish:weakSelf];
    };
    // update back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (--counter == 0) {
            block();
        }
    };
    WMParticipant *participant = self.appDelegate.participant;
    for (WMInterventionEvent *interventionEvent in participant.interventionEvents) {
        if (interventionEvent.ffUrl) {
            continue;
        }
        // else
        ++counter;
        ++counter;
        [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@", [WMInterventionEvent entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:participant.ffUrl grabBagName:WMParticipantRelationships.interventionEvents onComplete:completionHandler];
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:_woundTreatmentGroup.ffUrl grabBagName:WMWoundTreatmentGroupRelationships.interventionEvents onComplete:completionHandler];
        }];
    }
    for (WMWoundTreatmentValue *value in _woundTreatmentGroup.values) {
        ++counter;
        if (value.ffUrl) {
            [ff updateObj:value
               onComplete:completionHandler
                onOffline:completionHandler];
        } else {
            [ff createObj:value atUri:[NSString stringWithFormat:@"/%@", [WMWoundTreatmentValue entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff grabBagAddItemAtFfUrl:value.ffUrl toObjAtFfUrl:_woundTreatmentGroup.ffUrl grabBagName:WMWoundTreatmentGroupRelationships.values onComplete:completionHandler];
            }];
        }
    }
    ++counter;
    [ff updateObj:_woundTreatmentGroup onComplete:completionHandler];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.willCancelFlag && self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    if (self.didCreateGroup && _woundTreatmentGroup.ffUrl) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        for (WMWoundTreatmentValue *value in _woundTreatmentGroup.values) {
            if (value.ffUrl) {
                [ff grabBagRemove:value from:_woundTreatmentGroup grabBagName:WMWoundTreatmentGroupRelationships.values error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
                [ff deleteObj:value error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
            }
        }
        [ff grabBagRemove:_woundTreatmentGroup from:self.wound grabBagName:WMWoundRelationships.treatmentGroups error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_woundTreatmentGroup error:&error];
        if (error) {
            [WMUtilities logError:error];
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
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:viewController.parentWoundTreatment];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)woundTreatmentViewControllerDidCancel:(WMWoundTreatmentViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.fetchedResultsController indexPathForObject:self.selectedWoundTreatment]] withRowAnimation:UITableViewRowAnimationNone];
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
            // update back end
            [self deleteWoundTreatmentValue:previousWoundTreatmentValue];
        }
    } else {
        // existed, so selecting will remove value
        [self.woundTreatmentGroup removeValuesObject:woundTreatmentValue];
        [self.managedObjectContext deleteObject:woundTreatmentValue];
        // update back end
        [self deleteWoundTreatmentValue:woundTreatmentValue];
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

- (NSString *)ffQuery
{
    if (self.didCreateGroup) {
        return nil;
    }
    // else
    return [NSString stringWithFormat:@"%@/%@", self.woundTreatmentGroup.ffUrl, WMWoundTreatmentGroupRelationships.values];
}

- (NSArray *)backendSeedEntityNames
{
    return @[[WMWoundTreatment entityName]];
}

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

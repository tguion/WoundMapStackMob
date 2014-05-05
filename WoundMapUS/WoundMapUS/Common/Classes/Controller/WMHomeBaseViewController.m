//
//  WMHomeBaseViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//
//  TODO: make sure we do cache only unless explicitely set otherwise

#import "WMHomeBaseViewController.h"
#import "WMCarePlanTableViewCell.h"
#import "WMNavigationNodeButton.h"
#import "WMNavigationPatientPhotoButton.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMPatient.h"
#import "WMWoundMeasurement.h"
#import "WMBradenScale.h"
#import "WMMedicationGroup.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanValue.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMPhotoManager.h"
#import "WMPolicyManager.h"
#import "WMNavigationCoordinator.h"
#import "WMUserDefaultsManager.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import <objc/runtime.h>

#define kSignOutActionSheetTag 1000

@interface WMHomeBaseViewController () <UIActionSheetDelegate>

@property (readonly, nonatomic) WMChooseTrackViewController *chooseTrackViewController;
@property (readonly, nonatomic) WMChooseStageViewController *chooseStageViewController;
@property (readonly, nonatomic) WMPolicyEditorViewController *policyEditorViewController;

@property (strong, nonatomic) NSArray *patientNavigationNodes;
@property (strong, nonatomic) NSArray *woundNavigationNodes;
@property (strong, nonatomic) NSArray *patientNavigationNodeControls;
@property (strong, nonatomic) NSArray *woundNavigationNodeControls;

@property (nonatomic) BOOL removingTrackAndOrStageCells;
@property (nonatomic) BOOL updatePatientWoundComponentsInProgress;
@property (nonatomic) BOOL updateNavigationComponentsInProgress;

- (void)updatePatientWoundComponents;
- (void)updateWoundPhotoComponents;
- (void)updateNavigationComponents;

- (SEL)selectorForNavigationNode:(WMNavigationNode *)navigationNode;

- (void)delayedScrollTrackAndScopeOffTop;

@end

@implementation WMHomeBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
            [weakSelf.navigationPatientWoundContainerView updatePatientAndWoundNodes];
            [weakSelf updatePatientWoundComponents];
            [weakSelf performSelector:@selector(delayedScrollTrackAndScopeOffTop) withObject:nil afterDelay:1.0];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.title = @"Home";
    // instructions button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:self action:@selector(viewInstructionsAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    // show table view separators all the way across
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // make initial update to UI
    _patientWoundUIRequiresUpdate = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTitle];
    [self.navigationPatientWoundContainerView updatePatientAndWoundNodes];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // update UI
    if (nil != self.patient && _patientWoundUIRequiresUpdate) {
        _patientWoundUIRequiresUpdate = NO;
        [self updatePatientWoundComponents];
    }
    if (nil != self.patient && _navigationUIRequiresUpdate) {
        _navigationUIRequiresUpdate = NO;
        [self updateNavigationComponents];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self performSelector:@selector(delayedScrollTrackAndScopeOffTop) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSString *)ffQuery
{
    return  [NSString stringWithFormat:@"%@?depthRef=1&depthGb=2", self.patient.ffUrl];
}

- (NSArray *)backendSeedEntityNames
{
    return @[[WMNavigationNode entityName], [WMWoundMeasurement entityName]];
}

- (BOOL)shouldShowSelectTrackTableViewCell
{
    return (!self.removeTrackAndStageForSubnodes || nil == self.parentNavigationNode);
}

- (BOOL)shouldShowSelectStageTableViewCell
{
    return (!self.removeTrackAndStageForSubnodes || nil == self.parentNavigationNode) && !self.appDelegate.navigationCoordinator.navigationTrack.ignoresStagesFlag;
}

- (void)delayedScrollTrackAndScopeOffTop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedScrollTrackAndScopeOffTop) object:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.compassCell];
    if (nil != indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)updateTitle
{
    NSString *title = nil;
    if (nil == self.parentNavigationNode) {
        title = @"WoundMap";
    } else {
        title = self.parentNavigationNode.displayTitle;
    }
    self.title = title;
}

- (UITableViewCell *)carePlanCell
{
    if (nil == _carePlanCell) {
        _carePlanCell = [[WMCarePlanTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CarePlanCell"];
        _carePlanCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _carePlanCell.textLabel.text = @"Care Plan";
        _carePlanCell.imageView.image = [UIImage imageNamed:@"careplan_iPhone"];
    }
    return _carePlanCell;
}

- (void)setParentNavigationNode:(WMNavigationNode *)parentNavigationNode
{
    if (_parentNavigationNode == parentNavigationNode) {
        return;
    }
    // else
    _parentNavigationNode = parentNavigationNode;
    // clear our cache
    _navigationNodes = nil;
    _navigationNodeControls = nil;
    // update UI
    if (nil == self.view.window) {
        self.navigationUIRequiresUpdate = YES;
    } else {
        [self updateNavigationComponents];
        if (nil == parentNavigationNode) {
            [self reloadTableCellsForNavigation];
        }
    }
}

- (NSString *)breadcrumbString
{
    if (nil == _parentNavigationNode) {
        return @"WoundMap Home";
    }
    // else
    NSMutableArray *nodeTitles = [[NSMutableArray alloc] initWithObjects:@"Home", nil];
    WMNavigationNode *navigationNode = self.parentNavigationNode;
    while (nil != navigationNode) {
        [nodeTitles insertObject:navigationNode.displayTitle atIndex:1];
        navigationNode = navigationNode.parentNode;
    }
    return [nodeTitles componentsJoinedByString:@" > "];
}

- (WMNavigationNodeButton *)navigationControlForNavigationNode:(WMNavigationNode *)navigationNode rotationDirection:(MapBaseRotationDirection)rotationDirection
{
    WMNavigationNodeButton *button = [[WMNavigationNodeButton alloc] initWithNavigationNode:navigationNode rotationDirection:rotationDirection];
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeNavigationNodeControl:)];
    gestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [button addGestureRecognizer:gestureRecognizer];
    [button addTarget:self action:[self selectorForNavigationNode:navigationNode] forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSArray *)patientNavigationNodes
{
    if (nil == _patientNavigationNodes) {
        _patientNavigationNodes = [WMNavigationNode patientNodes:self.managedObjectContext];
    }
    return _patientNavigationNodes;
}

- (WMNavigationNode *)addPatientNavigationNode
{
    return [WMNavigationNode addPatientNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)selectPatientNavigationNode
{
    return [WMNavigationNode selectPatientNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)editPatientNavigationNode
{
    return [WMNavigationNode editPatientNavigationNode:self.managedObjectContext];
}

- (NSArray *)woundNavigationNodes
{
    if (nil == _woundNavigationNodes) {
        _woundNavigationNodes = [WMNavigationNode woundNodes:self.managedObjectContext];
    }
    return _woundNavigationNodes;
}

- (WMNavigationNode *)addWoundNavigationNode
{
    return [WMNavigationNode addWoundNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)selectWoundNavigationNode
{
    return [WMNavigationNode selectWoundNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)editWoundNavigationNode
{
    return [WMNavigationNode editWoundNavigationNode:self.managedObjectContext];
}

- (NSArray *)patientNavigationNodeControls
{
    if (nil == _patientNavigationNodeControls) {
        NSMutableArray *controls = [[NSMutableArray alloc] initWithCapacity:4];
        for (WMNavigationNode *navigationNode in self.patientNavigationNodes) {
            [controls addObject:[self navigationControlForNavigationNode:navigationNode rotationDirection:MapBaseRotationDirection_North]];
        }
        _patientNavigationNodeControls = controls;
    }
    return _patientNavigationNodeControls;
}

- (NSArray *)woundNavigationNodeControls
{
    if (nil == _woundNavigationNodeControls) {
        NSMutableArray *controls = [[NSMutableArray alloc] initWithCapacity:4];
        for (WMNavigationNode *navigationNode in self.woundNavigationNodes) {
            [controls addObject:[self navigationControlForNavigationNode:navigationNode rotationDirection:MapBaseRotationDirection_North]];
        }
        _woundNavigationNodeControls = controls;
    }
    return _woundNavigationNodeControls;
}

- (WMNavigationNode *)initialStageNavigationNode
{
    return [WMNavigationNode initialStageNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)followupStageNavigationNode
{
    return [WMNavigationNode followupStageNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)dischargeStageNavigationNode
{
    return [WMNavigationNode dischargeStageNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)browsePhotosNavigationNode
{
    return [WMNavigationNode browsePhotosNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)viewGraphsNavigationNode
{
    return [WMNavigationNode viewGraphsNavigationNode:self.managedObjectContext];
}

- (WMNavigationNode *)shareNavigationNode
{
    return [WMNavigationNode shareNavigationNode:self.managedObjectContext];
}

- (SEL)selectorForNavigationNode:(WMNavigationNode *)navigationNode
{
    SEL selector = nil;
    NavigationNodeIdentifier identifier = (NavigationNodeIdentifier)[navigationNode.taskIdentifier integerValue];
    switch (identifier) {
        case kInitialStageNode: {
            selector = @selector(selectInitialStageAction:);
            break;
        }
        case kFollowupStageNode: {
            selector = @selector(selectFollowupStageAction:);
            break;
        }
        case kDischargeStageNode: {
            selector = @selector(selectDischargeStageAction:);
            break;
        }
        case kSelectPatientNode: {
            selector = @selector(selectPatientAction:);
            break;
        }
        case kEditPatientNode: {
            selector = @selector(editPatientAction:);
            break;
        }
        case kAddPatientNode: {
            selector = @selector(addPatientAction:);
            break;
        }
        case kSelectWoundNode: {
            selector = @selector(selectWoundAction:);
            break;
        }
        case kEditWoundNode: {
            selector = @selector(editWoundAction:);
            break;
        }
        case kAddWoundNode: {
            selector = @selector(addWoundAction:);
            break;
        }
        case kWoundsNode: {
            selector = @selector(woundsAction:);
            break;
        }
        case kSelectStageNode: {
            selector = @selector(selectStageAction:);
            break;
        }
        case kRiskAssessmentNode: {
            selector = @selector(riskAssessmentAction:);
            break;
        }
        case kBradenScaleNode: {
            selector = @selector(bradenScaleAction:);
            break;
        }
        case kMedicationsNode: {
            selector = @selector(medicationAssessmentAction:);
            break;
        }
        case kDevicesNode: {
            selector = @selector(deviceAssessmentAction:);
            break;
        }
        case kPsycoSocialNode: {
            selector = @selector(psycoSocialAssessmentAction:);
            break;
        }
        case kSkinAssessmentNode: {
            selector = @selector(skinAssessmentAction:);
            break;
        }
        case kPhotoNode: {
            selector = @selector(photoAction:);
            break;
        }
        case kTakePhotoNode: {
            selector = @selector(takePhotoAction:);
            break;
        }
        case kMeasurePhotoNode: {
            selector = @selector(measurePhotoAction:);
            break;
        }
        case kWoundAssessmentNode: {
            selector = @selector(woundAssessmentAction:);
            break;
        }
        case kWoundTreatmentNode: {
            selector = @selector(woundTreatmentAction:);
            break;
        }
        case kCarePlanNode: {
            selector = @selector(carePlanAction:);
            break;
        }
        case kBrowsePhotosNode: {
            selector = @selector(browsePhotosAction:);
            break;
        }
        case kViewGraphsNode: {
            selector = @selector(viewGraphsAction:);
            break;
        }
        case kPatientSummaryNode: {
            // TODO finish
            break;
        }
        case kShareNode: {
            selector = @selector(shareAction:);
            break;
        }
        case kEmailReportNode: {
            selector = @selector(emailCADAction:);
            break;
        }
        case kPrintReportNode: {
            selector = @selector(printCADAction:);
            break;
        }
        case kPushEMRNode: {
            selector = @selector(pushToEMRAction:);
            break;
        }
    }
    return selector;
}

- (NSArray *)navigationNodes
{
    if (nil == _navigationNodes) {
        if (nil != _parentNavigationNode) {
            _navigationNodes = _parentNavigationNode.sortedSubnodes;
        } else {
            _navigationNodes = self.appDelegate.navigationCoordinator.navigationStage.rootNavigationNodes;
        }
    }
    return _navigationNodes;
}

- (NSArray *)navigationNodeControls
{
    if (nil == _navigationNodeControls) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
        NSInteger rotationDirection = 0;
        for (WMNavigationNode *navigationNode in self.navigationNodes) {
            [array addObject:[self navigationControlForNavigationNode:navigationNode rotationDirection:(MapBaseRotationDirection)rotationDirection]];
            ++rotationDirection;
        }
        _navigationNodeControls = array;
    }
    return _navigationNodeControls;
}

#pragma mark - Accessors

- (WMNavigationNodeButton *)selectPatientButton
{
    return self.navigationPatientWoundContainerView.patientSelectNavigationNodeButton;
}

- (WMNavigationNodeButton *)editPatientButton
{
    return self.navigationPatientWoundContainerView.patientEditNavigationNodeButton;
}

- (WMNavigationNodeButton *)addPatientButton
{
    return self.navigationPatientWoundContainerView.patientAddNavigationNodeButton;
}

- (WMNavigationNodeButton *)selectWoundButton
{
    return self.navigationPatientWoundContainerView.woundSelectNavigationNodeButton;
}

- (WMNavigationNodeButton *)editWoundButton
{
    return self.navigationPatientWoundContainerView.woundEditNavigationNodeButton;
}

- (WMNavigationNodeButton *)addWoundButton
{
    return self.navigationPatientWoundContainerView.woundAddNavigationNodeButton;
}

#pragma mark - Toolbar

- (void)updateToolbar
{
    [self setToolbarItems:self.toolbarItems];
    self.reviewPhotosBarButtonItem.enabled = ([WMWound woundPhotoCountForWound:self.wound] > 0 ? YES:NO);
}

- (NSArray *)toolbarItems
{
    if (nil == self.patient) {
        return [NSArray array];
    }
    // else
    NSMutableArray *toolbarItems = [NSMutableArray array];
    UIBarButtonItem *barButtonItem = nil;
    if (nil != self.wound) {
        // spacer
        [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        // browse photos
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photos"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(browsePhotosAction:)];
        [toolbarItems addObject:barButtonItem];
        self.reviewPhotosBarButtonItem = barButtonItem;
        // spacer
        [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        // view graphs
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"graph"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(viewGraphsAction:)];
        [toolbarItems addObject:barButtonItem];
        self.reviewGraphsBarButtonItem = barButtonItem;
    }
    // spacer
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    // patient summary
    barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chart"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(viewPatientSummaryAction:)];
    [toolbarItems addObject:barButtonItem];
    self.patientSummaryBarButtonItem = barButtonItem;
    // spacer
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    return toolbarItems;
}

#pragma mark - Model/View synchronization

- (void)reloadTableCellsForNavigation
{
    if (!self.removeTrackAndStageForSubnodes) {
        [self performSelector:@selector(delayedScrollTrackAndScopeOffTop) withObject:nil afterDelay:1.0];
        return;
    }
    // else
    if (nil == self.parentNavigationNode) {
        if (0 == [self.tableView.visibleCells count]) {
            [self.tableView reloadData];
        } else if (nil == self.stageTableViewCell.superview || nil == self.trackTableViewCell.superview) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:2];
            if (nil == self.trackTableViewCell.superview && self.shouldShowSelectTrackTableViewCell) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            if (nil == self.stageTableViewCell.superview && self.shouldShowSelectStageTableViewCell) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
            }
            if ([indexPaths count] > 0) {
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
            }
            [self performSelector:@selector(delayedScrollTrackAndScopeOffTop) withObject:nil afterDelay:1.0];
        }
    } else if (self.removeTrackAndStageForSubnodes) {
        if (nil != self.stageTableViewCell.superview || nil != self.trackTableViewCell.superview) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:2];
            [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            if (nil != self.stageTableViewCell.superview) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
            }
            if ([indexPaths count] > 0) {
                _removingTrackAndOrStageCells = YES;
                DLog(@"tableView.contentOffset: %@", NSStringFromCGPoint(self.tableView.contentOffset));
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
                self.tableView.contentOffset = CGPointZero;
            }
        }
    } else {
        [self performSelector:@selector(delayedScrollTrackAndScopeOffTop) withObject:nil afterDelay:1.0];
    }
}

- (void)updateNavigationBar
{
    // show policy editor if home
    NSMutableArray *items = [NSMutableArray array];
    if (nil == self.parentNavigationNode) {
        WMNavigationTrack *navigationTrack = self.appDelegate.navigationCoordinator.navigationTrack;
        if (!navigationTrack.skipPolicyEditor) {
            [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(editPoliciesAction:)]];
        }
        NSString *imageName = (self.appDelegate.participant.team ? @"ui_rabbit":@"ui_rabbit");
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(editUserOrTeamAction:)]];
    } else {
        NSString *imageName = nil;
        if (nil == self.parentNavigationNode.parentNode) {
            // one step from home
            imageName = @"home";
        } else {
            // more than one step from home
            imageName = @"homeback";
        }
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(homeAction:)]];
    }
    self.navigationItem.leftBarButtonItems = items;
}

- (void)updatePatientWoundComponents
{
    if (nil == self.view.window) {
        _patientWoundUIRequiresUpdate = YES;
        return;
    }
    // else
    if (_updatePatientWoundComponentsInProgress) {
        return;
    }
    _updatePatientWoundComponentsInProgress = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePatientWoundComponents) object:nil];
    [self.navigationPatientWoundContainerView updateContentForPatient];
    [self updateToolbar];
    [self performSelector:@selector(updateNavigationComponents) withObject:nil afterDelay:0.0];
    [self performSelector:@selector(updateWoundPhotoComponents) withObject:nil afterDelay:0.0];
    _updatePatientWoundComponentsInProgress = NO;
    _patientWoundUIRequiresUpdate = NO;
}

- (void)updateWoundPhotoComponents
{
    // ???
}

- (void)updateNavigationComponents
{
    if (nil == self.view.window) {
        _navigationUIRequiresUpdate = YES;
        return;
    }
    // else
    if (_updateNavigationComponentsInProgress) {
        return;
    }
    _updateNavigationComponentsInProgress = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateNavigationComponents) object:nil];
    // else update table cells
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.trackTableViewCell];
    if (nil != indexPath) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    indexPath = [self.tableView indexPathForCell:self.stageTableViewCell];
    if (nil != indexPath) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    // update other UI
    [self updateTitle];
    [self updateToolbar];
    [self updateNavigationBar];
    self.breadcrumbLabel.text = self.breadcrumbString;
    [self.compassView updateForPatient:self.patient];
    self.compassView.navigationNodeControls = self.navigationNodeControls;
    [self.compassView animateNodesIntoActivePosition];
    [self rotateCompassToRecommendedTask];
    [self enableOrDisableNavigationNodes];
    // update center of compass view
    self.compassView.patientPhotoView.navigationNodeTitle = self.parentNavigationNode.displayTitle;
    NSString *iconSuffix = (self.isIPadIdiom ? @"_iPad":@"_iPhone");
    self.compassView.patientPhotoView.navigationNodeIconName = [self.parentNavigationNode.icon stringByAppendingString:iconSuffix];
    self.compassView.actionState = (nil == self.parentNavigationNode ? CompassViewActionStateHome:CompassViewActionStateNone);
    WMNavigationStage *navigationStage = self.appDelegate.navigationCoordinator.navigationStage;
    NSInteger index = [[WMNavigationStage sortedStagesForTrack:self.appDelegate.navigationCoordinator.navigationTrack] indexOfObject:navigationStage];
    self.stageSegmentedControl.selectedSegmentIndex = index;
    _updateNavigationComponentsInProgress = NO;
}

- (void)rotateCompassToRecommendedTask
{
    if ([self.navigationNodes count] == 0) {
        // nothing to rotate to
        return;
    }
    // else
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    WMNavigationNode *navigationNode = [policyManager recommendedNavigationNodeForNavigationNodes:self.navigationNodes];
    NSInteger index = [self.navigationNodes indexOfObject:navigationNode];
    switch (index) {
        case MapBaseRotationDirection_West:
            [self.compassView rotateToWestAction:nil];
            break;
        case MapBaseRotationDirection_North:
            [self.compassView rotateToNorthAction:nil];
            break;
        case MapBaseRotationDirection_East:
            [self.compassView rotateToEastAction:nil];
            break;
        case MapBaseRotationDirection_South:
            [self.compassView rotateToSouthAction:nil];
            break;
    }
}

- (void)enableOrDisableNavigationNodes
{
    // patient - patientNavigationNodes:select, edit, add
    [self updatePatientNodeControls];
    // wound - woundNavigationNodeControls:select, edit, add
    [self updateWoundNodeControls];
    // task nodes
    [self updateTaskNodeControls];
}

- (UIImage *)openReferralStatusImage
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSString *imageName = (isPad ? @"alert_yellow_iPad":@"alert_yellow_iPhone");
    return [UIImage imageNamed:imageName];
}

// we need to adjust for
//  1. No patients (no documents)
//  2. Patients, but document not selected
//  3. Patient selected, but only one patient
//  4. Patient selected, 2 or more patients
- (void)updatePatientNodeControls
{
    WMPatient *patient = self.patient;
    NSInteger patientCount = [WMPatient patientCount:self.managedObjectContext];
    // select
    if (0 == patientCount) {
        // no patients (documents)
        self.selectPatientButton.enabled = NO;
    } else if (nil == patient) {
        // at least one patient, but none selected
        self.selectPatientButton.enabled = YES;
    } else {
        // patient not nil, so patient is selected - at least one patient exists
        self.selectPatientButton.enabled = (patientCount > 1 ? YES:NO);
    }
    // edit
    self.editPatientButton.enabled = (nil != patient);
}

- (void)updateWoundNodeControls
{
    WMPatient *patient = self.patient;
    WMWound *wound = self.wound;
    NSInteger woundCount = 0.0;
    if (nil != patient) {
        woundCount = [WMWound woundCountForPatient:patient];
    }
    // select
    if (nil == wound) {
        // we have wounds, but none selected
        self.selectWoundButton.enabled = woundCount > 0;
    } else if (woundCount < 2) {
        // wound is selected and only 1
        self.selectWoundButton.enabled = NO;
    } else {
        // wound selected and more than one
        self.selectWoundButton.enabled = YES;
    }
    // edit
    self.editWoundButton.enabled = (nil != wound);
    // handle referrals
    WMParticipant *participant = self.appDelegate.participant;
    NSArray *referrals = [participant targetPatientReferrals:YES];
    if ([referrals count]) {
        self.selectPatientButton.statusImageView.image = self.openReferralStatusImage;
    } else {
        self.selectPatientButton.statusImageView.image = nil;
    }
}

- (void)updateTaskNodeControls
{
    for (WMNavigationNodeButton *button in self.navigationNodeControls) {
        BOOL buttonEnabled = YES;
        BOOL requiresPatient = [button.navigationNode.requiresPatientFlag boolValue];
        BOOL requiresWound = [button.navigationNode.requiresWoundFlag boolValue];
        BOOL requiresWoundPhoto = [button.navigationNode.requiresWoundPhotoFlag boolValue];
        if (nil == self.patient && requiresPatient) {
            buttonEnabled = NO;
        }
        if (nil == self.wound && requiresWound) {
            buttonEnabled = NO;
        }
        if (nil == self.woundPhoto && requiresWoundPhoto) {
            buttonEnabled = NO;
        }
        button.enabled = buttonEnabled;
    }
}

// http://www.captechconsulting.com/blog/tyler-tillage/ios-7-tutorial-series-custom-navigation-transitions-more
- (void)animateNavigationNodeButtonIntoCompassCenter:(WMNavigationNodeButton *)navigationNodeButton
{
    // figure out the movement to the center
    WMNavigationNode *navigationNode = navigationNodeButton.navigationNode;
    CGRect sourceFrame = [self.view convertRect:navigationNodeButton.iconImageView.frame fromView:navigationNodeButton.iconImageView.superview];
    NSString *iconSuffix = (self.isIPadIdiom ? @"_iPad":@"_iPhone");
    CGRect targetFrame = [self.compassView.patientPhotoView navigationImageFrameForImageName:[navigationNode.icon stringByAppendingString:iconSuffix] title:navigationNode.displayTitle inView:self.view];
    CGFloat deltaX = CGRectGetMidX(targetFrame) - CGRectGetMidX(sourceFrame);
    CGFloat deltaY = CGRectGetMidY(targetFrame) - CGRectGetMidY(sourceFrame);
    // grab a snapshot of the button view for animating
    UIView *snapshot = [navigationNodeButton.iconImageView snapshotViewAfterScreenUpdates:NO];
    snapshot.frame = sourceFrame;
    [self.view addSubview:snapshot];
    [self.view bringSubviewToFront:snapshot];
    // animate using keyframe animation
    __weak __typeof(self) weakSelf = self;
    [UIView animateKeyframesWithDuration:1.0 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            // scale up and move half way
            CGAffineTransform scale = CGAffineTransformMakeScale(2.0, 2.0);
            CGAffineTransform translate = CGAffineTransformMakeTranslation(deltaX, deltaY);
            snapshot.transform = CGAffineTransformConcat(scale, translate);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            // scale down and move remaining half way
            CGAffineTransform scale = CGAffineTransformMakeScale(1.0, 1.0);
            CGAffineTransform translate = CGAffineTransformMakeTranslation(deltaX, deltaY);
            snapshot.transform = CGAffineTransformConcat(scale, translate);
            // fade out
            snapshot.alpha = 0.8;
        }];
    } completion:^(BOOL finished) {
        [snapshot removeFromSuperview];
        [weakSelf reloadTableCellsForNavigation];
    }];
}

#pragma mark - Notification handlers

- (void)handlePatientChanged:(WMPatient *)patient
{
    [super handlePatientChanged:patient];
    [self performSelector:@selector(updatePatientWoundComponents) withObject:nil afterDelay:0.0];
}

- (void)handleWoundChanged:(WMWound *)wound
{
    [super handleWoundChanged:wound];
    [self performSelector:@selector(updatePatientWoundComponents) withObject:nil afterDelay:0.0];
}

- (void)handleWoundPhotoChanged:(WMWoundPhoto *)woundPhoto
{
    [super handleWoundPhotoChanged:woundPhoto];
    [self performSelector:@selector(updateWoundPhotoComponents) withObject:nil afterDelay:0.0];
}

// patient navigationTrack changed
- (void)handleNavigationTrackChanged:(WMNavigationTrack *)navigationTrack
{
    [super handleNavigationTrackChanged:navigationTrack];
    [self performSelector:@selector(updateToolbar) withObject:nil afterDelay:0.0];
    [self performSelector:@selector(updateNavigationComponents) withObject:nil afterDelay:0.0];
}

// patient navigationStage changed
- (void)handleNavigationStageChanged:(WMNavigationStage *)navigationStage
{
    [super handleNavigationStageChanged:navigationStage];
    [self performSelector:@selector(updateNavigationComponents) withObject:nil afterDelay:0.0];
}

#pragma mark - Actions

- (IBAction)homeAction:(id)sender
{
    self.parentNavigationNode = self.parentNavigationNode.parentNode;
}

- (IBAction)editPoliciesAction:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:weakSelf.policyEditorViewController];
            [weakSelf presentViewController:navigationController animated:YES completion:^{
                // nothing
            }];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMNavigationTrackRelationships.stages]
                                              aggregator:self.appDelegate.navigationCoordinator.navigationTrack
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)editUserOrTeamAction:(id)sender
{
    WMTeam *team = self.appDelegate.participant.team;
    if (team && self.appDelegate.participant.isTeamLeader) {
        __weak __typeof(self) weakSelf = self;
        WMErrorCallback block = ^(NSError *error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            if (error) {
                [WMUtilities logError:error];
            } else {
                [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
                [weakSelf navigateToManageTeam:sender];
            }
        };
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMTeamRelationships.invitations, WMTeamRelationships.participants, WMTeamRelationships.patients]
                                                  aggregator:team
                                                          ff:[WMFatFractal sharedInstance]
                                           completionHandler:block];
    } else {
        // no team, sign out
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Sign Out %@", self.appDelegate.participant.userName]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Sign Out"
                                                        otherButtonTitles:nil];
        actionSheet.tag = kSignOutActionSheetTag;
        [actionSheet showInView:self.view];
    }
}

- (IBAction)selectInitialStageAction:(id)sender
{
    WMNavigationCoordinator *navigationCoordinator = self.appDelegate.navigationCoordinator;
    navigationCoordinator.navigationStage = [WMNavigationStage initialStageForTrack:navigationCoordinator.navigationTrack];
}

- (IBAction)selectFollowupStageAction:(id)sender
{
    WMNavigationCoordinator *navigationCoordinator = self.appDelegate.navigationCoordinator;
    navigationCoordinator.navigationStage = [WMNavigationStage followupStageForTrack:navigationCoordinator.navigationTrack];
}

- (IBAction)selectDischargeStageAction:(id)sender
{
    WMNavigationCoordinator *navigationCoordinator = self.appDelegate.navigationCoordinator;
    navigationCoordinator.navigationStage = [WMNavigationStage dischargeStageForTrack:navigationCoordinator.navigationTrack];
}

- (IBAction)selectPatientAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    [self navigateToSelectPatient:navigationNodeButton];
}

- (IBAction)editPatientAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    [self navigateToPatientDetail:navigationNodeButton];
}

- (IBAction)addPatientAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // create patient
    [self navigateToPatientDetailViewControllerForNewPatient:navigationNodeButton];
}

- (IBAction)selectWoundAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf navigateToSelectWound:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.wounds]
                                              aggregator:self.patient
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)editWoundAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    [self navigateToWoundDetail:navigationNodeButton];
}

- (IBAction)addWoundAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // create new wound
    NSParameterAssert(nil != self.patient);
    [self navigateToWoundDetailViewControllerForNewWound:navigationNodeButton];
}

- (IBAction)woundsAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf navigateToWounds:navigationNodeButton.navigationNode];
            [weakSelf animateNavigationNodeButtonIntoCompassCenter:navigationNodeButton];
        }
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
    };
    if (nil == self.wound) {
        block(nil);
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMWoundRelationships.measurementGroups, WMWoundRelationships.photos, WMWoundRelationships.treatmentGroups]
                                                  aggregator:self.wound
                                                          ff:[WMFatFractal sharedInstance]
                                           completionHandler:block];
    }
}

- (IBAction)chooseTrackAction:(id)sender
{
    [self navigateToNavigationTracks];
}

- (IBAction)selectStageAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    WMNavigationTrack *navigationTrack = self.appDelegate.navigationCoordinator.navigationTrack;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
            // initial (admit)
            self.appDelegate.navigationCoordinator.navigationStage = [WMNavigationStage initialStageForTrack:navigationTrack];
            break;
        }
        case 1: {
            // follow-up
            self.appDelegate.navigationCoordinator.navigationStage = [WMNavigationStage followupStageForTrack:navigationTrack];
            break;
        }
        case 2: {
            // discharge
            self.appDelegate.navigationCoordinator.navigationStage = [WMNavigationStage dischargeStageForTrack:navigationTrack];
            break;
        }
    }
}

- (IBAction)riskAssessmentAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    WMNavigationNode *navigationNode = navigationNodeButton.navigationNode;
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            weakSelf.parentNavigationNode = navigationNode;
            [weakSelf animateNavigationNodeButtonIntoCompassCenter:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.bradenScales, WMPatientRelationships.deviceGroups, WMPatientRelationships.medicalHistoryGroups, WMPatientRelationships.psychosocialGroups]
                                              aggregator:self.patient
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)bradenScaleAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // update from back end
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            if ([navigationNodeButton.navigationNode requiresIAPForWoundType:weakSelf.wound.woundType]) {
                // show IAP purchase view controller with self as delegate
                
                return;
            }
            // else
            [weakSelf navigateToBradenScaleAssessment:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.bradenScales]
                                              aggregator:self.patient
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

// IAP: mock up for medication node having an IAP
- (IBAction)medicationAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"sender:%@ must be NavigationNodeButton", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // update from back end
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            if (nil != navigationNodeButton.navigationNode.iapIdentifier) {
                BOOL proceed = [self presentIAPViewControllerForProductIdentifier:navigationNodeButton.navigationNode.iapIdentifier
                                                      successBlock:^{
                                                          [weakSelf navigateToMedicationAssessment:navigationNodeButton];
                                                      } withObject:navigationNodeButton];
                if (!proceed) {
                    return;
                }
            }
            // else
            [weakSelf navigateToMedicationAssessment:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.medicationGroups]
                                              aggregator:self.patient
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)deviceAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // update from back end
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf navigateToDeviceAssessment:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.deviceGroups]
                                              aggregator:self.patient
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)psycoSocialAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // update from back end
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf navigateToPsychoSocialAssessment:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.psychosocialGroups]
                                              aggregator:self.patient
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)skinAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf navigateToSkinAssessmentForNavigationNode:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.skinAssessmentGroups]
                                             aggregator:self.patient
                                                     ff:[WMFatFractal sharedInstance]
                                      completionHandler:block];
}

- (IBAction)photoAction:(id)sender
{
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    WMNavigationNode *navigationNode = navigationNodeButton.navigationNode;
    // attempt to set the last woundPhoto
    if (nil == self.appDelegate.navigationCoordinator.woundPhoto) {
        self.appDelegate.navigationCoordinator.woundPhoto = self.wound.lastWoundPhoto;
    }
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf navigateToPhoto:navigationNode];
            [weakSelf animateNavigationNodeButtonIntoCompassCenter:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMWoundRelationships.measurementGroups, WMWoundRelationships.treatmentGroups, WMWoundRelationships.photos]
                                              aggregator:self.wound
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)handleSwipeNavigationNodeControl:(UISwipeGestureRecognizer *)gestureRecognizer
{
    WMNavigationNodeButton *button = (WMNavigationNodeButton *)gestureRecognizer.view;
    WMNavigationNode *navigationNode = button.navigationNode;
    NavigationNodeIdentifier navigationNodeIdentifier = navigationNode.navigationNodeIdentifier;
    WMPhotoManager *photoManager = [WMPhotoManager sharedInstance];
    switch (navigationNodeIdentifier) {
        case kTakePhotoNode: {
            photoManager.usePhotoLibraryForNextPhoto = YES;
            [self takePhotoAction:button];
            break;
        }
        default:
            break;
    }
}

- (IBAction)takePhotoAction:(id)sender
{
    self.photoAcquisitionState = PhotoAcquisitionStateAcquireWoundPhoto;
    [self navigateToTakePhoto:(WMNavigationNodeButton *)sender];
}

// the action depends on parentNavigationNode
- (IBAction)takePatientPhotoAction:(id)sender
{
    if (nil == self.parentNavigationNode) {
        // we are home, so take photo
        self.photoAcquisitionState = PhotoAcquisitionStateAcquirePatientPhoto;
    } else {
        // navigate toward home
        self.parentNavigationNode = self.parentNavigationNode.parentNode;
    }
}

- (IBAction)measurePhotoAction:(id)sender
{
    [self navigateToMeasurePhoto];
}

- (IBAction)woundAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // update from back end
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf navigateToWoundAssessment:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMWoundRelationships.measurementGroups]
                                              aggregator:self.wound
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)woundTreatmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    // update from back end
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf navigateToWoundTreatment:navigationNodeButton];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMWoundRelationships.treatmentGroups]
                                              aggregator:self.wound
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)carePlanAction:(id)sender
{
    // update from back end
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf navigateToCarePlan];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WMFatFractalManager sharedInstance] updateGrabBags:@[WMPatientRelationships.carePlanGroups]
                                              aggregator:self.patient
                                                      ff:[WMFatFractal sharedInstance]
                                       completionHandler:block];
}

- (IBAction)browsePhotosAction:(id)sender
{
    if (nil == self.wound) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Wound Selected"
                                                            message:@"A wound with photos must be selected to display wound photos"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else
    if (self.wound.woundPhotosCount == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wound has no Photos"
                                                            message:[NSString stringWithFormat:@"Wound %@ has no photos", self.wound.shortName]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else update from back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    WMWound *wound = self.wound;
    NSSet *woundPhotos = wound.photos;
    __block NSInteger counter = [woundPhotos count];
    __weak __typeof(self) weakSelf = self;
    WMErrorCallback block1 = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (--counter == 0) {
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            [weakSelf navigateToBrowsePhotos:sender];
        }
    };
    WMErrorCallback block0 = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            // update woundPhoto grab bags
            for (WMWoundPhoto *woundPhoto in woundPhotos) {
                [ffm updateGrabBags:@[WMWoundPhotoRelationships.photos]
                         aggregator:woundPhoto
                                 ff:ff
                  completionHandler:block1];
            }
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ffm updateGrabBags:@[WMWoundRelationships.measurementGroups, WMWoundRelationships.treatmentGroups, WMWoundRelationships.photos]
             aggregator:wound
                     ff:ff
      completionHandler:block0];
}

- (IBAction)viewGraphsAction:(id)sender
{
    [self navigateToViewGraphs:sender];
}

- (IBAction)viewPatientSummaryAction:(id)sender
{
    [self navigateToPatientSummary:sender];
}

- (IBAction)shareAction:(id)sender
{
    [self navigateToShare:sender];
}

- (IBAction)emailCADAction:(id)sender
{
    // not from here
}

- (IBAction)printCADAction:(id)sender
{
    // not from here
}

- (IBAction)pushToEMRAction:(id)sender
{
    // not from here
}

- (IBAction)viewInstructionsAction:(id)sender
{
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:self.instructionsViewController] animated:YES completion:^{
        // nothing
    }];
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kSignOutActionSheetTag: {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                self.appDelegate.participant = nil;
                [self.appDelegate.navigationCoordinator clearPatientCache];
                WMFatFractal *ff = [WMFatFractal sharedInstance];
                [ff logout];
                __weak __typeof(self) weakSelf = self;
                [UIView transitionWithView:self.appDelegate.window
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{
                                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:weakSelf.welcomeToWoundMapViewController];
                                    navigationController.delegate = weakSelf.appDelegate;
                                    self.appDelegate.window.rootViewController = navigationController;
                                } completion:^(BOOL finished) {
                                    // nothing
                                }];
            }
            break;
        }
    }
}

#pragma mark - Navigation

- (void)navigateToPatientDetail:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToPatientDetailViewControllerForNewPatient:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToSelectPatient:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToWoundDetail:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToWoundDetailViewControllerForNewWound:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToSelectWound:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToSkinAssessmentForNavigationNode:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToBradenScaleAssessment:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToMedicationAssessment:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToDeviceAssessment:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToPsychoSocialAssessment:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToSkinAssessment:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToTakePhoto:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToMeasurePhoto:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToWoundAssessment:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToWoundTreatment:(WMNavigationNodeButton *)navigationNodeButton {}
- (void)navigateToBrowsePhotos:(id)sender {}
- (void)navigateToViewGraphs:(id)sender {}
- (void)navigateToPatientSummary:(id)sender {}
- (void)navigateToShare:(id)sender {}
- (void)navigateToManageTeam:(UIBarButtonItem *)barButtonItem {}

- (void)navigateToNavigationTracks
{
    [self.navigationController pushViewController:self.chooseTrackViewController animated:YES];
}

- (void)navigateToWounds:(WMNavigationNode *)navigationNode
{
    self.parentNavigationNode = navigationNode;
}

- (void)navigateToPhoto:(WMNavigationNode *)navigationNode
{
    self.parentNavigationNode = navigationNode;
}

- (void)navigateToMeasurePhoto
{
    [self.appDelegate.navigationCoordinator viewController:self beginMeasurementsForWoundPhoto:self.woundPhoto addingPhoto:NO];
}

- (void)navigateToCarePlan
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    WMNavigationNode *navigationNode = [WMNavigationNode carePlanNavigationNode:self.managedObjectContext];
    NSInteger count = [policyManager closeExpiredRecords:navigationNode];
    WMCarePlanGroupViewController *carePlanGroupViewController = self.carePlanGroupViewController;
    carePlanGroupViewController.recentlyClosedCount = count;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:carePlanGroupViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

#pragma mark - View Controllers

- (WMPolicyEditorViewController *)policyEditorViewController
{
    WMPolicyEditorViewController *policyEditorViewController = [[WMPolicyEditorViewController alloc] initWithNibName:@"WMPolicyEditorViewController" bundle:nil];
    policyEditorViewController.delegate = self;
    return policyEditorViewController;
}

- (WMManageTeamViewController *)manageTeamViewController
{
    return [[WMManageTeamViewController alloc] initWithNibName:@"WMManageTeamViewController" bundle:nil];
}

- (WMWelcomeToWoundMapViewController *)welcomeToWoundMapViewController
{
    return [[WMWelcomeToWoundMapViewController alloc] initWithNibName:@"WMWelcomeToWoundMapViewController" bundle:nil];
}

- (WMChooseTrackViewController *)chooseTrackViewController
{
    WMChooseTrackViewController *chooseTrackViewController = [[WMChooseTrackViewController alloc] initWithNibName:@"WMChooseTrackViewController" bundle:nil];
    chooseTrackViewController.delegate = self;
    return chooseTrackViewController;
}

- (WMChooseStageViewController *)chooseStageViewController
{
    WMChooseStageViewController *chooseStageViewController = [[WMChooseStageViewController alloc] initWithNibName:@"WMChooseStageViewController" bundle:nil];
    chooseStageViewController.delegate = self;
    return chooseStageViewController;
}

- (WMPatientTableViewController *)patientTableViewController
{
    WMPatientTableViewController *patientTableViewController = [[WMPatientTableViewController alloc] initWithNibName:@"WMPatientTableViewController" bundle:nil];
    patientTableViewController.delegate = self;
    return patientTableViewController;
}

- (WMPatientDetailViewController *)patientDetailViewController
{
    WMPatientDetailViewController *patientDetailViewController = [[WMPatientDetailViewController alloc] initWithNibName:@"WMPatientDetailViewController" bundle:nil];
    patientDetailViewController.delegate = self;
    return patientDetailViewController;
}

- (WMSelectWoundViewController *)selectWoundViewController
{
    WMSelectWoundViewController *selectWoundViewController = [[WMSelectWoundViewController alloc] initWithNibName:@"WMSelectWoundViewController" bundle:nil];
    selectWoundViewController.delegate = self;
    return selectWoundViewController;
}

- (WMWoundDetailViewController *)woundDetailViewController
{
    WMWoundDetailViewController *woundDetailViewController = [[WMWoundDetailViewController alloc] initWithNibName:@"WMWoundDetailViewController" bundle:nil];
    woundDetailViewController.delegate = self;
    return woundDetailViewController;
}

- (WMBradenScaleViewController *)bradenScaleViewController
{
    WMBradenScaleViewController *bradenScaleViewController = [[WMBradenScaleViewController alloc] initWithNibName:@"WMBradenScaleViewController" bundle:nil];
    bradenScaleViewController.delegate = self;
    return bradenScaleViewController;
}

- (WMMedicationGroupViewController *)medicationsViewController
{
    WMMedicationGroupViewController *medicationsViewController = [[WMMedicationGroupViewController alloc] initWithNibName:@"WMMedicationGroupViewController" bundle:nil];
    medicationsViewController.delegate = self;
    return medicationsViewController;
}

- (WMDevicesViewController *)devicesViewController
{
    WMDevicesViewController *devicesViewController = [[WMDevicesViewController alloc] initWithNibName:@"WMDevicesViewController" bundle:nil];
    devicesViewController.delegate = self;
    return devicesViewController;
}

- (WMPsychoSocialGroupViewController *)psychoSocialGroupViewController
{
    WMPsychoSocialGroupViewController *psychoSocialGroupViewController = [[WMPsychoSocialGroupViewController alloc] initWithNibName:@"WMPsychoSocialGroupViewController" bundle:nil];
    psychoSocialGroupViewController.delegate = self;
    return psychoSocialGroupViewController;
}

- (WMSkinAssessmentGroupViewController *)skinAssessmentGroupViewController
{
    WMSkinAssessmentGroupViewController *skinAssessmentGroupViewController = [[WMSkinAssessmentGroupViewController alloc] initWithNibName:@"WMSkinAssessmentGroupViewController" bundle:nil];
    skinAssessmentGroupViewController.delegate = self;
    return skinAssessmentGroupViewController;
}

- (WMCarePlanGroupViewController *)carePlanGroupViewController
{
    WMCarePlanGroupViewController *carePlanGroupViewController = [[WMCarePlanGroupViewController alloc] initWithNibName:@"WMCarePlanGroupViewController" bundle:nil];
    carePlanGroupViewController.delegate = self;
    return carePlanGroupViewController;
}

- (WMInstructionsViewController *)instructionsViewController
{
    return [[WMInstructionsViewController alloc] initWithNibName:@"WMInstructionsViewController" bundle:nil];
}

- (WMPhotosContainerViewController *)photosContainerViewController
{
    return [[WMPhotosContainerViewController alloc] initWithNibName:@"WMPhotosContainerViewController" bundle:nil];
}

- (WMPlotSelectDatasetViewController *)plotSelectDatasetViewController
{
    WMPlotSelectDatasetViewController *plotSelectDatasetViewController = [[WMPlotSelectDatasetViewController alloc] initWithNibName:@"WMPlotSelectDatasetViewController" bundle:nil];
    plotSelectDatasetViewController.delegate = self;
    return plotSelectDatasetViewController;
}

- (WMPatientSummaryContainerViewController *)patientSummaryContainerViewController
{
    WMPatientSummaryContainerViewController *patientSummaryContainerViewController = [[WMPatientSummaryContainerViewController alloc] initWithNibName:@"WMPatientSummaryContainerViewController" bundle:nil];
    patientSummaryContainerViewController.delegate = self;
    return patientSummaryContainerViewController;
}

- (WMShareViewController *)shareViewController
{
    WMShareViewController *shareViewController = [[WMShareViewController alloc] initWithNibName:@"WMShareViewController" bundle:nil];
    shareViewController.delegate = self;
    return shareViewController;
}

- (WMWoundTreatmentGroupsViewController *)woundTreatmentGroupsViewController
{
    WMWoundTreatmentGroupsViewController *woundTreatmentGroupsViewController = [[WMWoundTreatmentGroupsViewController alloc] initWithNibName:@"WMWoundTreatmentGroupsViewController" bundle:nil];
    woundTreatmentGroupsViewController.delegate = self;
    return woundTreatmentGroupsViewController;
}

- (WMWoundMeasurementGroupViewController *)woundMeasurementGroupViewController
{
    WMWoundMeasurementGroupViewController *woundMeasurementGroupViewController = [[WMWoundMeasurementGroupViewController alloc] initWithNibName:@"WMWoundMeasurementGroupViewController" bundle:nil];
    woundMeasurementGroupViewController.delegate = self;
    return woundMeasurementGroupViewController;
}

- (WMTakePatientPhotoViewController *)takePatientPhotoViewController
{
    WMTakePatientPhotoViewController *takePatientPhotoViewController = [[WMTakePatientPhotoViewController alloc] initWithNibName:@"WMTakePatientPhotoViewController" bundle:nil];
    takePatientPhotoViewController.delegate = self;
    return takePatientPhotoViewController;
}

#pragma mark - BaseViewController

- (void)registerForNotifications
{
    [super registerForNotifications];
    // adjust when task completes
    __weak __typeof(self) weakSelf = self;
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kTaskDidCompleteNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [weakSelf performSelector:@selector(updateNavigationComponents) withObject:nil afterDelay:0.0];
                                                                }];
    [self.persistantObservers addObject:observer];
    // pull down our popover
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                                 object:nil
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *notification) {
                                                                 [weakSelf handleApplicationWillResignActiveNotification];
                                                             }];
    [self.persistantObservers addObject:observer];
}

- (void)clearDataCache
{
    [super clearDataCache];
    [self clearNavigationCache];
    [self.compassView updateForPatient:nil];
}

- (void)clearNavigationCache
{
    _parentNavigationNode = nil;
    _navigationNodes = nil;
    _navigationNodeControls = nil;
}

#pragma mark - PolicyEditorDelegate

- (void)policyEditorViewControllerDidSave:(WMPolicyEditorViewController *)viewController
{
    self.navigationNodes = nil;
    self.navigationNodeControls = nil;
    self.navigationUIRequiresUpdate = YES;
    [self dismissViewControllerAnimated:YES completion:^{
        // reload navigation on view did appear
    }];
}

- (void)policyEditorViewController:(WMPolicyEditorViewController *)viewController didChangeTrack:(WMNavigationTrack *)navigationTrack
{
    self.appDelegate.navigationCoordinator.navigationTrack = navigationTrack;
}

- (void)policyEditorViewControllerDidCancel:(WMPolicyEditorViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - ChooseTrackDelegate

- (NSPredicate *)navigationTrackPredicate
{
    return [NSPredicate predicateWithFormat:@"team == %@", self.appDelegate.participant.team];
}

- (void)chooseTrackViewController:(WMChooseTrackViewController *)viewController didChooseNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    if (nil == navigationTrack || [self.patient.stage.track isEqual:navigationTrack]) {
        return;
    }
    // else let navigationCoordinator update patient and defaults
    self.appDelegate.navigationCoordinator.navigationTrack = navigationTrack;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)chooseTrackViewControllerDidCancel:(WMChooseTrackViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ChooseStageDelegate

- (WMNavigationTrack *)navigationTrack
{
    return self.appDelegate.navigationCoordinator.navigationTrack;
}

- (WMNavigationStage *)navigationStage
{
    return self.appDelegate.navigationCoordinator.navigationStage;
}

- (void)chooseStageViewController:(WMChooseStageViewController *)chooseStageViewController didSelectNavigationStage:(WMNavigationStage *)navigationStage
{
    self.appDelegate.navigationCoordinator.navigationStage = navigationStage;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)chooseStageViewControllerDidCancel:(WMChooseStageViewController *)chooseStageViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PatientDetailViewControllerDelegate

- (void)patientDetailViewControllerDidUpdatePatient:(WMPatientDetailViewController *)viewController
{
    // update our reference to current patient
    self.appDelegate.navigationCoordinator.patient = viewController.patient;
}

- (void)patientDetailViewControllerDidCancelUpdate:(WMPatientDetailViewController *)viewController {}

#pragma mark - PatientTableViewControllerDelegate

- (void)patientTableViewController:(WMPatientTableViewController *)viewController didSelectPatient:(WMPatient *)patient
{
    // update our reference to current patient
    if (nil != patient) {
        self.appDelegate.navigationCoordinator.patient = patient;
    }
}

- (void)patientTableViewControllerDidCancel:(WMPatientTableViewController *)viewController {}

#pragma mark - SelectWoundViewControllerDelegate

- (void)selectWoundController:(WMSelectWoundViewController *)viewController didSelectWound:(WMWound *)wound
{
    self.appDelegate.navigationCoordinator.wound = wound;
}

- (void)selectWoundControllerDidCancel:(WMSelectWoundViewController *)viewController
{
}

#pragma mark - WoundDetailViewControllerDelegate

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didUpdateWound:(WMWound *)wound
{
    self.appDelegate.navigationCoordinator.wound = wound;
    // save
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    // update UI
    [self.navigationPatientWoundContainerView updateContentForPatient];
    __weak __typeof(&*self)weakSelf = self;
    // commit to back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ff updateObj:wound onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
    }];
}

- (void)woundDetailViewControllerDidCancelUpdate:(WMWoundDetailViewController *)viewController
{
}

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didDeleteWound:(WMWound *)wound
{
    [self updatePatientWoundComponents];
}

#pragma mark - BradenScaleDelegate

- (void)bradenScaleControllerDidFinish:(WMBradenScaleViewController *)viewController
{
    // save in order to update updatedAt
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kBradenScaleNode]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
        }
    }];
}

#pragma mark - MedicationGroupViewControllerDelegate

- (void)medicationGroupViewControllerDidSave:(WMMedicationGroupViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kMedicationsNode]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
}

- (void)medicationGroupViewControllerDidCancel:(WMMedicationGroupViewController *)viewController
{
    // may have removed all medications for group, and then deleted the group, so update interface
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kMedicationsNode]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
}

#pragma mark - DevicesViewControllerDelegate

- (void)devicesViewControllerDidSave:(WMDevicesViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kDevicesNode]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
}

- (void)devicesViewControllerDidCancel:(WMDevicesViewController *)viewController
{
}

#pragma mark - PsychoSocialGroupViewControllerDelegate

- (void)psychoSocialGroupViewControllerDidFinish:(WMPsychoSocialGroupViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kPsycoSocialNode]];
}

- (void)psychoSocialGroupViewControllerDidCancel:(WMPsychoSocialGroupViewController *)viewController
{
}

#pragma mark - SkinAssessmentGroupViewControllerDelegate

- (void)skinAssessmentGroupViewControllerDidSave:(WMSkinAssessmentGroupViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kSkinAssessmentNode]];
}

- (void)skinAssessmentGroupViewControllerDidCancel:(WMSkinAssessmentGroupViewController *)viewController
{
}

#pragma mark - TakePatientPhotoDelegate

- (void)takePatientPhotoViewControllerDidFinish:(WMTakePatientPhotoViewController *)viewController
{
    [self.compassView updateForPatientPhotoProcessed];
    [self.compassView updateForPatient:self.patient];
    self.photoAcquisitionState = PhotoAcquisitionStateNone;
}

#pragma mark - OverlayViewControllerDelegate

- (void)photoManager:(WMPhotoManager *)photoManager didCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata
{
    switch (self.photoAcquisitionState) {
        case PhotoAcquisitionStateNone: {
            NSAssert(NO, @"acquire photo in invalid state");
            break;
        }
        case PhotoAcquisitionStateAcquireWoundPhoto: {
            WMWound *wound = self.wound;
            NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
            MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            progressHUD.labelText = @"Processing Photo";
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            // have photoManager start the process
            FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                }
                [managedObjectContext MR_saveToPersistentStoreAndWait];
            };
            WMObjectsCallback createPhotoComplete = ^(NSError *error, id object0, id object1) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    WMWoundPhoto *woundPhoto = (WMWoundPhoto *)object0;
                    WMPhoto *photo = (WMPhoto *)object1;
                    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    [ff updateBlob:UIImagePNGRepresentation(photo.photo)
                      withMimeType:@"image/png"
                            forObj:photo
                        memberName:WMPhotoAttributes.photo
                        onComplete:onComplete onOffline:onComplete];
                    [ff grabBagAddItemAtFfUrl:photo.ffUrl
                                 toObjAtFfUrl:woundPhoto.ffUrl
                                  grabBagName:WMWoundPhotoRelationships.photos
                                   onComplete:onComplete];
                }
            };
            WMObjectsCallback createWoundPhotoComplete = ^(NSError *error, id object0, id object1) {
                if (error) {
                    [WMUtilities logError:error];
                }
                WMWoundPhoto *woundPhoto = (WMWoundPhoto *)object0;
                WMPhoto *photo = (WMPhoto *)object1;
                NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
                // readd the photo
                [woundPhoto addPhotosObject:photo];
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                [ff createObj:photo
                        atUri:[NSString stringWithFormat:@"/%@", [WMPhoto entityName]]
                   onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                       createPhotoComplete(error, woundPhoto, photo);
                   } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                       createPhotoComplete(error, woundPhoto, photo);
                   }];
                [ff updateBlob:UIImagePNGRepresentation(image)
                  withMimeType:@"image/png"
                        forObj:woundPhoto
                    memberName:WMWoundPhotoAttributes.thumbnail
                    onComplete:onComplete onOffline:onComplete];
                [ff updateBlob:UIImagePNGRepresentation(image)
                  withMimeType:@"image/png"
                        forObj:woundPhoto
                    memberName:WMWoundPhotoAttributes.thumbnailLarge
                    onComplete:onComplete onOffline:onComplete];
                [ff updateBlob:UIImagePNGRepresentation(image)
                  withMimeType:@"image/png"
                        forObj:woundPhoto
                    memberName:WMWoundPhotoAttributes.thumbnailMini
                    onComplete:onComplete onOffline:onComplete];
                [ff grabBagAddItemAtFfUrl:woundPhoto.ffUrl
                             toObjAtFfUrl:wound.ffUrl
                              grabBagName:WMWoundRelationships.photos
                               onComplete:onComplete];
            };
            [photoManager processNewImage:image
                                 metadata:metadata
                                    wound:self.wound
                        completionHandler:^(NSError *error, id object) {
                            if (error) {
                                [WMUtilities logError:error];
                            }
                            WMWoundPhoto *woundPhoto = (WMWoundPhoto *)object;
                            WMPhoto *photo = [woundPhoto.photos anyObject];
                            // save the photo
                            __weak __typeof(&*self)weakSelf = self;
                            NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
                            [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                                if (error) {
                                    [WMUtilities logError:error];
                                }
                                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                                weakSelf.appDelegate.navigationCoordinator.woundPhoto = woundPhoto;
                                [weakSelf updateToolbar];
                                // notify interface of completed task
                                [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kTakePhotoNode]];
                                // save to back end - first break the relationship
                                [woundPhoto removePhotosObject:photo];
                                [ff createObj:woundPhoto
                                        atUri:[NSString stringWithFormat:@"/%@", [WMWoundPhoto entityName]]
                                   onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                       createWoundPhotoComplete(error, woundPhoto, photo);
                                   } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                       createWoundPhotoComplete(error, woundPhoto, photo);
                                   }];
                            }];
                        }];
            break;
        }
        case PhotoAcquisitionStateAcquirePatientPhoto: {
            // should not be here
            self.photoAcquisitionState = PhotoAcquisitionStateNone;
            break;
        }
    }
}

- (void)photoManagerDidCancelCaptureImage:(WMPhotoManager *)photoManager
{
    // subclass
}

#pragma mark - CarePlanGroupViewControllerDelegate

- (void)carePlanGroupViewControllerDidSave:(WMCarePlanGroupViewController *)viewController
{
    __weak __typeof(&*self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        // post notification if some values were added
        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kCarePlanNode)];
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:self.carePlanCell];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)carePlanGroupViewControllerDidCancel:(WMCarePlanGroupViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - WoundTreatmentGroupsDelegate

- (void)woundTreatmentGroupsViewControllerDidFinish:(WMWoundTreatmentGroupsViewController *)viewController
{
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kWoundTreatmentNode)];
}

- (void)woundTreatmentGroupsViewControllerDidCancel:(WMWoundTreatmentGroupsViewController *)viewController
{
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController
{
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kWoundAssessmentNode)];
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController
{
}

#pragma mark - SimpleTableViewControllerDelegate

- (NSString *)navigationTitle
{
    return @"Hello";
}

- (NSArray *)valuesForDisplay
{
    return [NSArray array];
}

- (NSArray *)selectedValuesForDisplay
{
    return [NSArray array];
}

- (void)simpleTableViewController:(WMSimpleTableViewController *)simpleTableViewController didSelectValues:(NSArray *)selectedValues
{
}

- (void)simpleTableViewControllerDidCancel:(WMSimpleTableViewController *)simpleTableViewController
{
}

#pragma mark - PlotViewControllerDelegate

- (void)plotViewControllerDidCancel:(WMBaseViewController *)viewController
{
}

- (void)plotViewControllerDidFinish:(WMBaseViewController *)viewController
{
}

#pragma mark - PatientSummaryContainerDelegate

- (void)patientSummaryContainerViewControllerDidFinish:(WMPatientSummaryContainerViewController *)viewController
{
}

#pragma mark - ShareViewControllerDelegate

- (void)shareViewControllerDidFinish:(WMShareViewController *)viewController
{
}

#pragma mark - UIAlertViewDelegate

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return CGRectGetHeight(self.navigationPatientWoundContainerView.frame);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.navigationPatientWoundContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.section) {
                case 0: {
                    NSInteger row = indexPath.row;
                    BOOL showBothTrackAndStage = (self.shouldShowSelectTrackTableViewCell && self.shouldShowSelectStageTableViewCell);
                    BOOL showEitherTrackOrStage = ((self.shouldShowSelectTrackTableViewCell && !self.shouldShowSelectStageTableViewCell) || (!self.shouldShowSelectTrackTableViewCell && self.shouldShowSelectStageTableViewCell));
                    BOOL showNoneTrackAndStage = (!self.shouldShowSelectTrackTableViewCell && !self.shouldShowSelectStageTableViewCell);
                    if (row == 0 && self.shouldShowSelectTrackTableViewCell) {
                        // track
                        height = 44.0;
                    } else if (self.shouldShowSelectStageTableViewCell && ((row == 1 && self.shouldShowSelectTrackTableViewCell) || (row == 0 && !self.shouldShowSelectTrackTableViewCell))) {
                        // stage
                        height = 44.0;
                    } else if ((row == 2 && showBothTrackAndStage) ||
                               (row == 1 && showEitherTrackOrStage) ||
                               (row == 0 && showNoneTrackAndStage)) {
                        // compass
                        height = (self.isIPadIdiom ? 576.0:288.0);
                    } else if ((row == 3 && showBothTrackAndStage) ||
                               (row == 2 && showEitherTrackOrStage) ||
                               (row == 1 && showNoneTrackAndStage)) {
                        // care plan
                        height = (self.isIPadIdiom ? 88.0:44.0);
                    }
                    break;
                }
            }
            break;
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_removingTrackAndOrStageCells) {
        _removingTrackAndOrStageCells = NO;
        // we removed Track/Stage
        [self delayedScrollTrackAndScopeOffTop];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView cellForRowAtIndexPath:indexPath] == self.trackTableViewCell) {
        [self chooseTrackAction:nil];
    } else if ([tableView cellForRowAtIndexPath:indexPath] == self.carePlanCell) {
        [self carePlanAction:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (nil == self.patient ? 0:1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 4;
    if (self.patient.stage.track.skipCarePlanFlag) {
        count -= 1;
    }
    if (!self.shouldShowSelectTrackTableViewCell) {
        count -= 1;
    }
    if (!self.shouldShowSelectStageTableViewCell) {
        count -= 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0: {
            NSInteger row = indexPath.row;
            BOOL showBothTrackAndStage = (self.shouldShowSelectTrackTableViewCell && self.shouldShowSelectStageTableViewCell);
            BOOL showEitherTrackOrStage = ((self.shouldShowSelectTrackTableViewCell && !self.shouldShowSelectStageTableViewCell) || (!self.shouldShowSelectTrackTableViewCell && self.shouldShowSelectStageTableViewCell));
            BOOL showNoneTrackAndStage = (!self.shouldShowSelectTrackTableViewCell && !self.shouldShowSelectStageTableViewCell);
            if (row == 0 && self.shouldShowSelectTrackTableViewCell) {
                cell = self.trackTableViewCell;
            } else if (self.shouldShowSelectStageTableViewCell && ((row == 1 && self.shouldShowSelectTrackTableViewCell) || (row == 0 && !self.shouldShowSelectTrackTableViewCell))) {
                cell = self.stageTableViewCell;
            } else if ((row == 2 && showBothTrackAndStage) ||
                       (row == 1 && showEitherTrackOrStage) ||
                       (row == 0 && showNoneTrackAndStage)) {
                cell = self.compassCell;
            } else if ((row == 3 && showBothTrackAndStage) ||
                       (row == 2 && showEitherTrackOrStage) ||
                       (row == 1 && showNoneTrackAndStage)) {
                cell = self.carePlanCell;
            }
            break;
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (cell == self.trackTableViewCell) {
        cell.textLabel.text = @"Clinical Setting";
        cell.detailTextLabel.text = self.patient.stage.track.displayTitle;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (cell == self.carePlanCell) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld items", (long)[WMCarePlanValue valueCountForCarePlanGroup:[WMCarePlanGroup activeCarePlanGroup:self.patient]]];
    }
}

@end

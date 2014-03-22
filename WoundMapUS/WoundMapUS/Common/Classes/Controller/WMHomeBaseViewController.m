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
#import "WMPatient.h"
#import "WMBradenScale.h"
#import "WMMedicationGroup.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMPhotoManager.h"
#import "WMPolicyManager.h"
#import "WMNavigationCoordinator.h"
#import "WMUserDefaultsManager.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import <objc/runtime.h>

@interface WMHomeBaseViewController ()

@property (readonly, nonatomic) WMChooseTrackViewController *chooseTrackViewController;
@property (readonly, nonatomic) WMChooseStageViewController *chooseStageViewController;
@property (readonly, nonatomic) WMPolicyEditorViewController *policyEditorViewController;

@property (nonatomic) BOOL removingTrackAndOrStageCells;
@property (nonatomic) BOOL updatePatientWoundComponentsInProgress;
@property (nonatomic) BOOL updateNavigationComponentsInProgress;

- (void)updatePatientWoundComponents;
- (void)updateWoundPhotoComponents;
- (void)updateNavigationComponents;

- (void)delayedScrollTrackAndScopeOffTop;

@end

@implementation WMHomeBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (BOOL)shouldShowSelectTrackTableViewCell
{
    return (!self.removeTrackAndStageForSubnodes || nil == self.parentNavigationNode);
}

- (void)delayedScrollTrackAndScopeOffTop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedScrollTrackAndScopeOffTop) object:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.compassCell];
    if (nil != indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
    if (nil == self.parentNavigationNode) {
        WMNavigationTrack *navigationTrack = self.appDelegate.navigationCoordinator.navigationTrack;
        if (!sel_isEqual(self.navigationItem.leftBarButtonItem.action, @selector(editPoliciesAction:)) && !navigationTrack.skipPolicyEditor) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"]
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(editPoliciesAction:)];
        } else if (navigationTrack.skipPolicyEditor) {
            self.navigationItem.leftBarButtonItem = nil;
        }
    } else {
        NSString *imageName = nil;
        if (nil == self.parentNavigationNode.parentNode) {
            // one step from home
            imageName = @"home";
        } else {
            // more than one step from home
            imageName = @"homeback";
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(homeAction:)];
    }
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
    self.parentNavigationNode = nil;
    self.breadcrumbLabel.text = self.breadcrumbString;
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
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.policyEditorViewController];
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
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
    [self navigateToWoundDetail:navigationNodeButton];
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
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    NSAssert(ffm.isCacheEmpty, @"Expected ffm cache to be empty");
    NSString *patientFFURL = self.patient.ffUrl;
    NSAssert([patientFFURL length] > 0, @"Expected patient.ffUrl");
    WMWound *wound = [WMWound instanceWithPatient:self.patient];
    [ffm createObject:wound ffUrl:[WMWound entityName] ff:ff addToQueue:NO completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMWound *wound = (WMWound *)object;
        NSString *woundFFURL = wound.ffUrl;
        NSAssert([woundFFURL length] > 0, @"Expected wound.ffUrl");
        [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            [ff queueGrabBagAddItemAtUri:woundFFURL toObjAtUri:patientFFURL grabBagName:WMPatientRelationships.wounds];
        }];
    }];
    self.appDelegate.navigationCoordinator.wound = wound;
    [self navigateToWoundDetailViewControllerForNewWound:navigationNodeButton];
}

- (IBAction)woundsAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    [self navigateToWounds:navigationNodeButton.navigationNode];
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
    if ([navigationNode.subnodes count] > 0) {
        // this should have subnodes, just being anal
        [self animateNavigationNodeButtonIntoCompassCenter:navigationNodeButton];
    }
}

- (IBAction)bradenScaleAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    if ([navigationNodeButton.navigationNode requiresIAPForWoundType:self.wound.woundType]) {
        // show IAP purchase view controller with self as delegate
        
        return;
    }
    // else
    [self navigateToBradenScaleAssessment:navigationNodeButton];
}

// IAP: mock up for medication node having an IAP
- (IBAction)medicationAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"sender:%@ must be NavigationNodeButton", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    if (nil != navigationNodeButton.navigationNode.iapIdentifier) {
        BOOL proceed = [self presentIAPViewControllerForProductIdentifier:navigationNodeButton.navigationNode.iapIdentifier successSelector:@selector(navigateToMedicationAssessment:) withObject:navigationNodeButton];
        if (!proceed) {
            return;
        }
    }
    // else
    [self navigateToMedicationAssessment:navigationNodeButton];
}

- (IBAction)deviceAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToDeviceAssessment:navigationNodeButton];
}

- (IBAction)psycoSocialAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToPsychoSocialAssessment:navigationNodeButton];
}

- (IBAction)skinAssessmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToSkinAssessmentForNavigationNode:navigationNodeButton];
}

- (IBAction)photoAction:(id)sender
{
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    WMNavigationNode *navigationNode = navigationNodeButton.navigationNode;
    [self navigateToPhoto:navigationNode];
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
    navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToWoundAssessment:navigationNodeButton];
}

- (IBAction)woundTreatmentAction:(id)sender
{
    WMPolicyManager *policyManager = [WMPolicyManager sharedInstance];
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToWoundTreatment:navigationNodeButton];
}

- (IBAction)carePlanAction:(id)sender
{
    [self navigateToCarePlan];
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
    // else
    [self navigateToBrowsePhotos:sender];
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

#pragma mark - Navigation

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

#pragma mark - ChooseTrackDelegate

- (void)chooseTrackViewController:(WMChooseTrackViewController *)viewController didChooseNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    if (nil == navigationTrack || [self.patient.stage.track isEqual:navigationTrack]) {
        return;
    }
    // else let navigationCoordinator update patient and defaults
    self.appDelegate.navigationCoordinator.navigationTrack = navigationTrack;
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    
}

- (void)chooseTrackViewControllerDidCancel:(WMChooseTrackViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
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
    [chooseStageViewController clearAllReferences];
}

- (void)chooseStageViewControllerDidCancel:(WMChooseStageViewController *)chooseStageViewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [chooseStageViewController clearAllReferences];
}

#pragma mark - SelectWoundViewControllerDelegate

- (void)selectWoundController:(WMSelectWoundViewController *)viewController didSelectWound:(WMWound *)wound
{
    [viewController clearAllReferences];
    self.appDelegate.navigationCoordinator.wound = wound;
}

- (void)selectWoundControllerDidCancel:(WMSelectWoundViewController *)viewController
{
    [viewController clearAllReferences];
}

#pragma mark - WoundDetailViewControllerDelegate

- (void)woundDetailViewControllerDidUpdateWound:(WMWoundDetailViewController *)viewController
{
    // save
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            // commit to back end
            WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
            [ffm submitOperationsToQueue];
        } else {
            [WMUtilities logError:error];
        }
    }];
    // clear memory
    [viewController clearAllReferences];
    [self dismissViewControllerAnimated:YES completion:^{
        // update UI
        [self.navigationPatientWoundContainerView updateContentForPatient];
    }];
}

- (void)woundDetailViewControllerDidCancelUpdate:(WMWoundDetailViewController *)viewController
{
    if (viewController.isNewWound) {
        [self.appDelegate.navigationCoordinator deleteWound:viewController.wound];
    }
    // abort back end
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ffm clearOperationCache];
    [self dismissViewControllerAnimated:YES completion:^{
        // update UI
        [self.navigationPatientWoundContainerView updateContentForPatient];
    }];
}

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didDeleteWound:(WMWound *)wound
{
    NSString *patientFFURL = wound.patient.ffUrl;
    NSString *woundFFURL = wound.ffUrl;
    NSParameterAssert([patientFFURL length] > 0);
    NSParameterAssert([woundFFURL length] > 0);
    [self.appDelegate.navigationCoordinator deleteWound:wound];
    // save
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        // commit to back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
        [ffm deleteObject:wound ff:ff addToQueue:YES completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
            [ff queueGrabBagRemoveItemAtUri:woundFFURL fromObjAtUri:patientFFURL grabBagName:WMPatientRelationships.wounds];
        }];
    }];
    // clear memory
    [viewController clearAllReferences];
}

#pragma mark - BradenScaleDelegate

- (void)bradenScaleControllerDidFinish:(WMBradenScaleViewController *)viewController
{
    [viewController clearAllReferences];
    // save in order to update updatedAt
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kBradenScaleNode]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
        } else {
            [WMUtilities logError:error];
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
//    BOOL hasChanges = self.managedObjectContext.hasChanges;
//    BOOL hasValues = [viewController.deviceGroup.values count] > 0;
//    if (!hasValues) {
//        [self.managedObjectContext deleteObject:viewController.deviceGroup];
//        hasChanges = YES;
//    }
//    [viewController clearAllReferences];
//    // save in order to update updatedAt
//    NSError *error = nil;
//    [self.managedObjectContext saveAndWait:&error];
//    if (nil != error) {
//        [WMUtilities logError:error];
//    }
//    if (hasChanges) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kDevicesNode]];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
//    }
}

- (void)devicesViewControllerDidCancel:(WMDevicesViewController *)viewController
{
//    BOOL hasValues = [viewController.deviceGroup.values count] > 0;
//    if (!hasValues) {
//        [self.managedObjectContext deleteObject:viewController.deviceGroup];
//        NSError *error = nil;
//        [self.managedObjectContext saveAndWait:&error];
//        if (nil != error) {
//            [WMUtilities logError:error];
//        }
//    }
//    [viewController clearAllReferences];
}

#pragma mark - PsychoSocialGroupViewControllerDelegate

- (void)psychoSocialGroupViewControllerDidFinish:(WMPsychoSocialGroupViewController *)viewController
{
//    BOOL hasChanges = self.managedObjectContext.hasChanges;
//    BOOL hasValues = [viewController.psychoSocialGroup.values count] > 0;
//    if (!hasValues) {
//        [self.managedObjectContext deleteObject:viewController.psychoSocialGroup];
//        hasChanges = YES;
//    }
//    [viewController clearAllReferences];
//    // save in order to update updatedAt
//    NSError *error = nil;
//    [self.managedObjectContext saveAndWait:&error];
//    if (nil != error) {
//        [WMUtilities logError:error];
//    }
//    if (hasChanges) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kPsycoSocialNode]];
//    }
}

- (void)psychoSocialGroupViewControllerDidCancel:(WMPsychoSocialGroupViewController *)viewController
{
//    BOOL hasValues = [viewController.psychoSocialGroup.values count] > 0;
//    if (!hasValues) {
//        [self.managedObjectContext deleteObject:viewController.psychoSocialGroup];
//        NSError *error = nil;
//        [self.managedObjectContext saveAndWait:&error];
//        if (nil != error) {
//            [WMUtilities logError:error];
//        }
//    }
//    [viewController clearAllReferences];
}

#pragma mark - SkinAssessmentGroupViewControllerDelegate

- (void)skinAssessmentGroupViewControllerDidSave:(WMSkinAssessmentGroupViewController *)viewController
{
//    BOOL hasChanges = self.managedObjectContext.hasChanges;
//    BOOL hasValues = [viewController.skinAssessmentGroup.values count] > 0;
//    if (!hasValues) {
//        [self.managedObjectContext deleteObject:viewController.skinAssessmentGroup];
//        hasChanges = YES;
//    }
//    [viewController clearAllReferences];
//    // save in order to update updatedAt
//    NSError *error = nil;
//    [self.managedObjectContext saveAndWait:&error];
//    if (nil != error) {
//        [WMUtilities logError:error];
//    }
//    if (hasChanges) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kSkinAssessmentNode]];
//    }
}

- (void)skinAssessmentGroupViewControllerDidCancel:(WMSkinAssessmentGroupViewController *)viewController
{
//    BOOL hasValues = [viewController.skinAssessmentGroup.values count] > 0;
//    if (!hasValues) {
//        [self.managedObjectContext deleteObject:viewController.skinAssessmentGroup];
//        NSError *error = nil;
//        [self.managedObjectContext saveAndWait:&error];
//        if (nil != error) {
//            [WMUtilities logError:error];
//        }
//    }
//    [viewController clearAllReferences];
}

#pragma mark - TakePatientPhotoDelegate

- (void)takePatientPhotoViewControllerDidFinish:(WMTakePatientPhotoViewController *)viewController
{
    [viewController clearAllReferences];
    [self.compassView updateForPatientPhotoProcessed];
    [self.compassView updateForPatient:self.patient];
    self.photoAcquisitionState = PhotoAcquisitionStateNone;
}

#pragma mark - OverlayViewControllerDelegate

- (void)photoManager:(WMPhotoManager *)photoManager didCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata
{
//    switch (self.photoAcquisitionState) {
//        case PhotoAcquisitionStateNone: {
//            NSAssert(NO, @"acquire photo in invalid state");
//            break;
//        }
//        case PhotoAcquisitionStateAcquireWoundPhoto: {
//            [self showProgressViewWithMessage:@"Processing Photo"];
//            // have photoManager start the process
//            WMWoundPhoto *woundPhoto = [photoManager processNewImage:image
//                                                            metadata:metadata
//                                                               wound:self.wound];
//            // save the photo
//            [self.managedObjectContext saveOnSuccess:^{
//                [self hideProgressView];
//                // save the photo now and wait for save to complete
//                self.appDelegate.navigationCoordinator.woundPhoto = woundPhoto;
//                [self updateToolbar];
//                // notify interface of completed task
//                [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kTakePhotoNode]];
//            } onFailure:^(NSError *error) {
//                [self hideProgressView];
//                if (nil != error) {
//                    [WMUtilities logError:error];
//                }
//                // TODO show alert on fail
//            }];
//            self.photoAcquisitionState = PhotoAcquisitionStateNone;
//            self.savingWoundPhotoFlag = NO;
//            break;
//        }
//        case PhotoAcquisitionStateAcquirePatientPhoto: {
//            [self showProgressViewWithMessage:@"Processing Photo"];
//            // process image in background using self.photoManager scaleAndCenterPatientPhoto:(UIImage *)photo rect:(CGRect)rect
//            __weak __typeof(self) weakSelf = self;
//            [self.compassView updateForPatientPhotoProcessing];
//            NSData *theData = UIImagePNGRepresentation(image);
//            NSString *picData = [SMBinaryDataConversion stringForBinaryData:theData name:[NSString stringWithFormat:@"%@.raw", self.patient.wmpatient_id] contentType:@"image/png"];
//            patient.thumbnail = picData;
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                BOOL success = NO;
//                UIImage *face = [photoManager scaleAndCenterPatientPhoto:image rect:CGRectMake(0.0, 0.0, 256.0, 256.0) success:&success];
//                NSManagedObjectContext *managedObjectContext = [weakSelf.coreDataHelper.stackMobStore contextForCurrentThread];
//                WMPatient *patient = (WMPatient *)[managedObjectContext objectWithID:[weakSelf.patient objectID]];
//                if (success) {
//                    patient.faceDetectionFailed = NO;
//                    NSData *theData = UIImagePNGRepresentation(face);
//                    NSString *picData = [SMBinaryDataConversion stringForBinaryData:theData name:[NSString stringWithFormat:@"%@.face", patient.wmpatient_id] contentType:@"image/png"];
//                    patient.thumbnail = picData;
//                } else {
//                    patient.faceDetectionFailed = YES;
//                }
//                [managedObjectContext saveOnSuccess:^{
//                    [self hideProgressView];
//                    [weakSelf.compassView updateForPatientPhotoProcessed];
//                    [weakSelf.compassView updateForPatient:weakSelf.patient];
//                } onFailure:^(NSError *){
//                    [self hideProgressView];
//                }];
//            });
//            self.photoAcquisitionState = PhotoAcquisitionStateNone;
//            break;
//        }
//    }
}

- (void)photoManagerDidCancelCaptureImage:(WMPhotoManager *)photoManager
{
    // subclass
}

#pragma mark - CarePlanGroupViewControllerDelegate

- (void)carePlanGroupViewControllerDidSave:(WMCarePlanGroupViewController *)viewController
{
//    BOOL hasChanges = self.managedObjectContext.hasChanges;
//    // save in order to update updatedAt
//    NSError *error = nil;
//    [self.managedObjectContext saveAndWait:&error];
//    if (nil != error) {
//        [WMUtilities logError:error];
//    }
//    [viewController clearAllReferences];
//    [self dismissViewControllerAnimated:YES completion:^{
//        // post notification if some values were added
//        if (hasChanges) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kCarePlanNode)];
//        }
//    }];
}

- (void)carePlanGroupViewControllerDidCancel:(WMCarePlanGroupViewController *)viewController
{
    [viewController clearAllReferences];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - WoundTreatmentGroupsDelegate

- (void)woundTreatmentGroupsViewControllerDidFinish:(WMWoundTreatmentGroupsViewController *)viewController
{
//    [viewController clearAllReferences];
//    // save in order to update updatedAt
//    NSError *error = nil;
//    [self.managedObjectContext saveAndWait:&error];
//    if (nil != error) {
//        [WMUtilities logError:error];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kWoundTreatmentNode)];
}

- (void)woundTreatmentGroupsViewControllerDidCancel:(WMWoundTreatmentGroupsViewController *)viewController
{
    [viewController clearAllReferences];
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController
{
//    [viewController clearAllReferences];
//    // save in order to update updatedAt
//    NSError *error = nil;
//    [self.managedObjectContext saveAndWait:&error];
//    if (nil != error) {
//        [WMUtilities logError:error];
//    }
//    // notify interface of completed task
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kWoundAssessmentNode)];
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController
{
    [viewController clearAllReferences];
}

#pragma mark - PlotViewControllerDelegate

- (void)plotViewControllerDidCancel:(WMBaseViewController *)viewController
{
    [viewController clearAllReferences];
}

- (void)plotViewControllerDidFinish:(WMBaseViewController *)viewController
{
    [viewController clearAllReferences];
}

#pragma mark - PatientSummaryContainerDelegate

- (void)patientSummaryContainerViewControllerDidFinish:(WMPatientSummaryContainerViewController *)viewController
{
    [viewController clearAllReferences];
}

#pragma mark - ShareViewControllerDelegate

- (void)shareViewControllerDidFinish:(WMShareViewController *)viewController
{
    [viewController clearAllReferences];
}

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    // if we are to try again, check the status of our document
//    if (alertView.tag == kFailedToCreateAndSaveDocumentAlertTag) {
//        if (alertView.cancelButtonIndex == buttonIndex) {
//            return;
//        }
//        // else let's try to create/open a new document again
//        [self addPatientAction:nil];
//    }
//}

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
    }
}

@end

//
//  WMBaseViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"
#import "IAPAggregatorViewController.h"
#import "IAPNonConsumableViewController.h"
#import "MBProgressHUD.h"
#import "WMProgressViewHUD.h"
#import "WMNavigationNodeButton.h"
#import "WMUnderlayNavigationBar.h"
#import "WMUnderlayToolbar.h"
#import "WMParticipant.h"
#import "IAPProduct.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMUserDefaultsManager.h"
#import "WMUtilities.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "IAPManager.h"
#import "UIView+Custom.h"
#import "WCAppDelegate.h"

BOOL const kPresentIAPController = NO;  // DEPLOYMENT

@interface WMBaseViewController ()

@property (nonatomic) BOOL assignedContentInsets;
@property (nonatomic) BOOL calculatedContentInsets;
@property (nonatomic) UIInterfaceOrientation orientationForCalculatedInsets;
@property (nonatomic) CGRect applicationFrameForCalculatedInsets;
@property (nonatomic) BOOL keyboardIsShowing;
@property (nonatomic) UIEdgeInsets contentInsetsBeforeShowingKeyboard;

@property (strong, nonatomic) NSManagedObjectID *patientObjectID;
@property (strong, nonatomic) NSManagedObjectID *woundObjectID;
@property (strong, nonatomic) NSManagedObjectID *woundPhotoObjectID;

@property (strong, nonatomic) UIPopoverController *iapPopoverController;

@end

@implementation WMBaseViewController

@synthesize contentInsets = _contentInsets;

#pragma mark - View

- (void)dealloc
{
    DLog(@"%@.dealloc", self);
    _fetchedResultsController.delegate = nil;
    for (id observer in self.opaqueNotificationObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    for (id observer in self.persistantObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    DLog(@"%@ %@.viewDidLoad:", self, NSStringFromClass([self class]));
    [super viewDidLoad];
    self.tableView.rowHeight = 44.0;
    // initialize our refresh control and assign the refreshTable method to get called when the refresh is initiated.
    if ([self.ffQuery count]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // listen for stuff
    [self registerForNotifications];
    // make sure we have any seed data from back end
    [self acquireBackendDataForEntityNames:self.backendSeedEntityNames];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(observeKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(observeKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog(@"%@ %@.viewWillDisappear:", self, NSStringFromClass([self class]));
    [super viewWillDisappear:animated];
    // stop listening
    [self unregisterForNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Content Insets

- (UIEdgeInsets)contentInsets
{
    if (_assignedContentInsets)
        return _contentInsets;
    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    // If the content insets were calculated, and the orientation is the same, return calculated value
    if (_calculatedContentInsets && _orientationForCalculatedInsets == orientation && CGRectEqualToRect(applicationFrame, _applicationFrameForCalculatedInsets))
        return _contentInsets;
    
    // grab our frame in window coordinates
    CGRect rect = [self.view convertRect:self.view.bounds toView:nil];
    
    // No value has been assigned, so we need to compute it
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIApplication *application = [UIApplication sharedApplication];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (!application.statusBarHidden) {
        // The status bar is WEIRD. It doesn't seem to adjust when rotated.
        CGFloat height = (UIInterfaceOrientationIsPortrait(orientation) ? CGRectGetHeight(application.statusBarFrame) : CGRectGetWidth(application.statusBarFrame));
        
        if (CGRectGetMinY(rect) < height)
            insets.top += height;
    }
    
    // If the navigation bar ISN'T hidden, we'll set our top inset to the bottom of the navigation bar. This allows the system to position things correctly to account for the double height status bar.
    if (!navigationBar.hidden) {
        // During rotation, the navigation bar (and possibly tab bar) doesn't resize immediately. Force it to have it's new size.
        [navigationBar sizeToFit];
        CGRect frame = [navigationBar convertRect:navigationBar.bounds toView:nil];
        
        if (CGRectIntersectsRect(rect, frame))
            insets.top += CGRectGetMaxY(frame) - CGRectGetMinY(frame);
    }
    
    if (tabBar && !tabBar.hidden) {
        // During rotation, the navigation bar (and possibly tab bar) doesn't resize immediately. Force it to have it's new size.
        [tabBar sizeToFit];
        CGRect frame = [tabBar convertRect:tabBar.bounds toView:nil];
        if (CGRectIntersectsRect(rect, frame))
            insets.bottom = CGRectGetHeight(frame);
    }
    
    _calculatedContentInsets = YES;
    _orientationForCalculatedInsets = orientation;
    _applicationFrameForCalculatedInsets = applicationFrame;
    _contentInsets = insets;
    
    return insets;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    _calculatedContentInsets = NO;
    _assignedContentInsets = YES;
    
    // I hope this triggers the VCs -viewDidLayoutSubviews method, which is where view layout should occur.
    [self.view setNeedsLayout];
}

#pragma mark - Keyboard

- (void)observeKeyboardWillShowNotification:(NSNotification *)note
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if (isPad) {
        return;
    }

    CGFloat animationDuration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (_keyboardIsShowing)
        return;
    
    // The keyboard rect is WRONG for landscape
//    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
//        keyboardRect.origin = CGPointMake(keyboardRect.origin.y, keyboardRect.origin.x);
//        keyboardRect.size = CGSizeMake(keyboardRect.size.height, keyboardRect.size.width);
//    }
    
    _keyboardIsShowing = YES;
    
    UIEdgeInsets insets = self.contentInsets;
    // Remember the previous contentInsets
    _contentInsetsBeforeShowingKeyboard = insets;
    
    UIView *view = self.view;
    CGRect rect = [view convertRect:view.bounds toView:nil];
    
    // If the keyboard doesn't insersect the view's frame, then there's no need to adjust anything
    if (!CGRectIntersectsRect(keyboardRect, rect))
        return;
    
    // Jam the height of the keyboard as the bottom content inset
    insets.bottom = keyboardRect.size.height;
    // update the content insets, without flipping the assigned toggle.
    _contentInsets = insets;
    
    // Trigger a call to -viewWillLayoutSubviews inside the animation block
    [self.view setNeedsLayout];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)note
{
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if (isPad) {
        return;
    }

    CGFloat animationDuration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (!_keyboardIsShowing)
        return;
    
    _contentInsets = _contentInsetsBeforeShowingKeyboard;
    
    _keyboardIsShowing = NO;
    
    // Trigger a call to -viewWillLayoutSubviews inside the animation block
    [self.view setNeedsLayout];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Core

- (BOOL)isIPadIdiom
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

// clear any strong references to views
- (void)clearViewReferences
{
    UITableView *tableView = self.tableView;
    tableView.delegate = nil;
    tableView.dataSource = nil;
    self.view = nil;
}

- (void)clearDataCache
{
    _patientObjectID = nil;
    _woundObjectID = nil;
    _woundPhotoObjectID = nil;
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
}

- (void)clearAllReferences
{
    [self clearViewReferences];
    [self clearDataCache];
    [self removeAllObservers];
}

- (void)removeAllObservers
{
    for (id observer in _persistantObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    _persistantObservers = nil;
}

- (UITableViewCell *)cellForView:(UIView *)aView
{
	UIView *bView = aView.superview;
	while (nil != bView) {
		if ([bView isKindOfClass:[UITableViewCell class]]) {
			return (UITableViewCell *)bView;
		}
		// else
		bView = bView.superview;
	}
	// else
	return nil;
}

- (BOOL)isSearchActive
{
    return self.searchDisplayController.isActive;
}

- (UITableView *)activeTableView
{
    if (self.isSearchActive) {
        return self.searchDisplayController.searchResultsTableView;
    }
    // else
    return self.tableView;
}

#pragma mark - Actions

- (void)refreshTable
{
    NSArray *queries = self.ffQuery;
    if (0 == [queries count]) {
        return;
    }
    // else query looks like this: /ff/resources/WMMedicationGroup/dt0q2wQE-g8ZJxuS_9nEh5/medications
    __weak __typeof(&*self)weakSelf = self;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    __block NSInteger count = [queries count];
    for (NSString *query in queries) {
        NSString *q = [query stringByReplacingOccurrencesOfString:@"/ff/resources/" withString:@"/"];
        NSArray *components = [q componentsSeparatedByString:@"/"];
        [ff getArrayFromUri:q onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            if (0 == count || --count == 0) {
                // update the array if there is an aggregator
                if (weakSelf.aggregator) {
                    NSString *destinationKey = [components lastObject];
                    if (destinationKey) {
                        [weakSelf.aggregator setValue:[NSSet setWithArray:object] forKey:destinationKey];
                    }
                }
                // we must save here, since we may have picked up changes from cloud
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                // refresh the tableView
                [weakSelf.tableView reloadData];
                if (weakSelf.refreshCompletionHandler) {
                    weakSelf.refreshCompletionHandler(error, nil);
                }
                [weakSelf.refreshControl endRefreshing];
            }
        }];
    }
}

- (IBAction)previousAction:(id)sender
{
    UIView *view = (UIView *)[self.view findFirstResponder];
    UITableViewCell *cell = [self cellForView:view];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    while (section >= 0) {
        while (--row >= 0) {
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                UIResponder *responder = [self firstResponderInViews:@[cell]];
                if (responder) {
                    [responder becomeFirstResponder];
                    return;
                }
            }
        }
        --section;
        if (section >= 0) {
            row = [self.tableView numberOfRowsInSection:section];
        }
    }
}

- (IBAction)nextAction:(id)sender
{
    UIView *view = (UIView *)[self.view findFirstResponder];
    UITableViewCell *cell = [self cellForView:view];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger sectionCount = [self.tableView numberOfSections];
    while (section < sectionCount) {
        NSInteger rowCount = [self.tableView numberOfRowsInSection:section];
        while (++row < rowCount) {
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                UIResponder *responder = [self firstResponderInViews:@[cell]];
                if (responder) {
                    [responder becomeFirstResponder];
                    return;
                }
            }
        }
        ++section;
        row = -1;
    }
}

- (IBAction)dismissAction:(id)sender
{
    [self.view endEditing:YES];
}

- (UIResponder *)firstResponderInViews:(NSArray *)views
{
    for (UIView *view in views) {
        if ([view conformsToProtocol:@protocol(UITextInput)]) {
            return (UIResponder *)view;
        }
        // else
        UIResponder *responder = [self firstResponderInViews:view.subviews];
        if (responder) {
            return responder;
        }
    }
    // else
    return nil;
}

#pragma mark - Input Accessory View

- (UIToolbar *)inputAccessoryView
{
    if (nil == _inputAccessoryView) {
        // load the next/previous buttons
        _inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 44.0)];
        UIBarButtonItem *fixedWidthBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                                 target:nil
                                                                                                 action:NULL];
        fixedWidthBarButtonItem.width = 20.0;
        NSArray *barButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard_back"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(previousAction:)],
                                    fixedWidthBarButtonItem,
                                    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard_forward"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(nextAction:)],
                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:NULL],
                                    [[UIBarButtonItem alloc] initWithTitle:@"Dismiss"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismissAction:)]];
        _inputAccessoryView.items = barButtonItems;
    }
    return _inputAccessoryView;
}

#pragma mark - Progress view

- (WMProgressViewHUD *)progressView
{
    if (nil == _progressView) {
        _progressView = [[WMProgressViewHUD alloc] initWithFrame:CGRectZero];
    }
    return _progressView;
}

- (void)showProgressView
{
    if (nil != _progressView.superview) {
        return;
    }
    // else
    [self.view addSubview:self.progressView];
}

- (void)showProgressViewWithMessage:(NSString *)message
{
    if (nil == _progressView.superview) {
        [self.view addSubview:self.progressView];
    }
    _progressView.messageLabel.text = message;
}

- (void)hideProgressView
{
    if (nil == _progressView.superview) {
        // check for missed views
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[WMProgressViewHUD class]]) {
                [view removeFromSuperview];
            }
        }
        _progressView = nil;
        return;
    }
    // else
    [_progressView removeFromSuperview];
    _progressView = nil;
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    __weak __typeof(&*self)weakSelf = self;
    // check if we are already registered
    if (0 == [self.opaqueNotificationObservers count]) {
        // add observers
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextWillSaveNotification
                                                                            object:[NSManagedObjectContext MR_defaultContext]
                                                                             queue:[NSOperationQueue mainQueue]
                                                                        usingBlock:^(NSNotification *notification) {
                                                                            [weakSelf handleDefaultManagedObjectContextWillSave:notification];
                                                                        }];
        [self.opaqueNotificationObservers addObject:observer];
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kTeamInvitationNotification
                                                                        object:nil
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *notification) {
                                                                        [weakSelf handleTeamInvitationUpdated:notification.object];
                                                                    }];
        [self.opaqueNotificationObservers addObject:observer];
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kPatientReferralNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handlePatientReferralUpdated:notification.object];
                                                                 }];
        [self.opaqueNotificationObservers addObject:observer];
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kTeamMemberAddedNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handleTeamMemberAdded:notification.object];
                                                                 }];
        [self.opaqueNotificationObservers addObject:observer];
    }
    if (0 == [self.persistantObservers count]) {
        // update for change in patient
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kPatientChangedNotification
                                                                        object:nil
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *notification) {
                                                                        WMPatient *patient = (WMPatient *)[weakSelf.managedObjectContext objectWithID:[notification object]];
                                                                        [weakSelf handlePatientChanged:patient];
                                                                    }];
        [self.persistantObservers addObject:observer];
        // update for change in wound
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kWoundChangedNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     WMWound *wound = (WMWound *)[weakSelf.managedObjectContext objectWithID:[notification object]];
                                                                     [weakSelf handleWoundChanged:wound];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // update for change in woundPhoto
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kWoundPhotoChangedNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     WMWoundPhoto *woundPhoto = (WMWoundPhoto *)[weakSelf.managedObjectContext objectWithID:[notification object]];
                                                                     [weakSelf handleWoundPhotoChanged:woundPhoto];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // update for change in track
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kNavigationTrackChangedNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     WMNavigationTrack *navigationTrack = (WMNavigationTrack *)[weakSelf.managedObjectContext objectWithID:[notification object]];
                                                                     [weakSelf handleNavigationTrackChanged:navigationTrack];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // update for change in stage
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kNavigationStageChangedNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     WMNavigationStage *navigationStage = (WMNavigationStage *)[weakSelf.managedObjectContext objectWithID:[notification object]];
                                                                     [weakSelf handleNavigationStageChanged:navigationStage];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // watch for participant responding to referral
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kRespondedToReferralNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handleRespondedToReferralNotification:[notification object]];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // watch for objects deleted by another device or team member from back end
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kBackendDeletedObjectIDs
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handleBackendDeletedObjectIds:[notification object]];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // watch for patient data refreshing from back end
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kPatientRefreshingFromCloudNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handlePatientRefreshingFromCloud:[notification object]];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // watch for patient data refreshing from back end finished
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kPatientUpdatedFromBackendNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handlePatientRefreshedFromCloud:[notification object]];
                                                                 }];
        [self.persistantObservers addObject:observer];
        // watch for content-available from cloud
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kUpdatedContentFromCloudNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     NSDictionary *map = notification.object;
                                                                     NSDictionary *userInfo = notification.userInfo;
                                                                     DLog(@"%@ updating from cloud:%@, userInfo:%@", weakSelf, map, userInfo);
                                                                     [weakSelf handleContentUpdatedFromCloud:map userInfo:userInfo];
                                                                 }];
        [self.persistantObservers addObject:observer];
    }
}

- (void)unregisterForNotifications
{
    // stop listening
    for (id observer in self.opaqueNotificationObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [self.opaqueNotificationObservers removeAllObjects];
}

#pragma mark - Notification handlers

- (void)handleDefaultManagedObjectContextWillSave:(NSNotification *)notification
{
    
}

- (void)patientNavigationDataChangedOnDevice
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPatientNavigationDataChangedOnDeviceNotification object:self.patient];
}

- (void)handleParticipantLoggedOut
{
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ffm showLoginWithTitle:@"Sign In" andMessage:@"Your session has expired. You must sign in again to continue."];
}

- (void)handleApplicationWillResignActiveNotification
{
    __block UIViewController *viewController = self.appDelegate.window.rootViewController.presentedViewController;
    if (nil != viewController) {
        // do not dismiss during IAP
        if ([viewController isKindOfClass:[IAPBaseViewController class]]) {
            return;
        }
        NSMutableArray *viewControllers = [NSMutableArray array];
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            for (UIViewController *vc in navigationController.viewControllers) {
                // do not dismiss during IAP
                if ([vc isKindOfClass:[IAPBaseViewController class]]) {
                    return;
                }
            }
            [viewControllers addObjectsFromArray:navigationController.viewControllers];
        } else {
            [viewControllers addObject:viewController];
        }
        [viewController dismissViewControllerAnimated:NO completion:^{
            for (WMBaseViewController *viewController in viewControllers) {
                if ([viewController respondsToSelector:@selector(clearAllReferences)]) {
                    [viewController performSelector:@selector(clearAllReferences)];
                }
            }
        }];
    }
}

- (void)handlePatientChanged:(WMPatient *)patient
{
}

- (void)handleWoundChanged:(WMWound *)wound
{
    
}

- (void)handleWoundPhotoChanged:(WMWoundPhoto *)woundPhoto
{
}

// patient navigationTrack changed
- (void)handleNavigationTrackChanged:(WMNavigationTrack *)navigationTrack
{
}

- (void)handleNavigationStageChanged:(WMNavigationStage *)navigationStage
{
}

- (void)handleRespondedToReferralNotification:(NSManagedObjectID *)referralObjectID
{
}

- (void)handleBackendDeletedObjectIds:(NSArray *)objectIDs
{
}

- (void)handlePatientRefreshingFromCloud:(NSManagedObjectID *)patientObjectId
{
}

- (void)handlePatientRefreshedFromCloud:(NSManagedObjectID *)patientObjectId
{
    [self.tableView reloadData];
}

- (void)handleContentUpdatedFromCloud:(NSDictionary *)map userInfo:(NSDictionary *)userInfo
{
    [self.tableView reloadData];
}

- (void)handleTeamInvitationUpdated:(NSString *)teamInvitationGUID
{
}

- (void)handleTeamMemberAdded:(NSString *)teamGUID
{
    [self.tableView reloadData];
}

- (void)handlePatientReferralUpdated:(NSString *)patientGUID
{
    [self refreshTable];
}

#pragma mark - Accessors

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (CoreDataHelper *)coreDataHelper
{
    return self.appDelegate.coreDataHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    WM_ASSERT_MAIN_THREAD;
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSPersistentStore *)store
{
    return self.appDelegate.coreDataHelper.store;
}

- (NSArray *)backendSeedEntityNames
{
    return [NSArray array];
}

- (void)acquireBackendDataForEntityNames:(NSArray *)entityNames
{
    for (NSString *entityName in entityNames) {
        [self acquireBackendDataForEntityName:entityName];
    }
}

- (void)acquireBackendDataForEntityName:(NSString *)backendSeedEntityName
{
    if (backendSeedEntityName && ![self.coreDataHelper isBackendDataAcquiredForEntityName:backendSeedEntityName]) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [MBProgressHUD showHUDAddedToViewController:self animated:YES];
        __weak __typeof(&*self)weakSelf = self;
        [ff getArrayFromUri:[NSString stringWithFormat:@"/%@?depthRef=1&depthGb=1", backendSeedEntityName] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            [weakSelf.coreDataHelper markBackendDataAcquiredForEntityName:backendSeedEntityName];
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            if (weakSelf.refreshCompletionHandler) {
                weakSelf.refreshCompletionHandler(error, backendSeedEntityName);
            }
        }];
    }
}

- (WMUserDefaultsManager *)userDefaultsManager
{
    return [WMUserDefaultsManager sharedInstance];
}

- (NSMutableArray *)opaqueNotificationObservers
{
    if (nil == _opaqueNotificationObservers) {
        _opaqueNotificationObservers = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _opaqueNotificationObservers;
}

- (NSMutableArray *)persistantObservers
{
    if (nil == _persistantObservers) {
        _persistantObservers = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return _persistantObservers;
}

#pragma mark - Active data

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

- (WMWoundPhoto *)woundPhoto
{
    return self.appDelegate.navigationCoordinator.woundPhoto;
}

#pragma mark - IAP proceedAlways

- (BOOL)presentIAPViewControllerForProductIdentifier:(NSString *)productIdentifier
                                        successBlock:(IAPPresentViewControllerAcceptHandler)successBlock
                                          withObject:(id)object
{
    return [self presentIAPViewControllerForProductIdentifier:productIdentifier
                                                 successBlock:(IAPPresentViewControllerAcceptHandler)successBlock
                                                proceedAlways:NO
                                                   withObject:object];
}

- (BOOL)presentIAPViewControllerForProductIdentifier:(NSString *)productIdentifier
                                        successBlock:(IAPPresentViewControllerAcceptHandler)successBlock
                                       proceedAlways:(BOOL)proceedAlways
                                          withObject:(id)object
{
    return [self presentIAPViewControllerForProductIdentifier:productIdentifier
                                                 successBlock:successBlock
                                                proceedAlways:proceedAlways
                                                   withObject:object
                                                     quantity:1];
}

- (BOOL)presentIAPViewControllerForProductIdentifier:(NSString *)productIdentifier
                                        successBlock:(IAPPresentViewControllerAcceptHandler)successBlock
                                       proceedAlways:(BOOL)proceedAlways
                                          withObject:(id)object
                                            quantity:(NSInteger)quantity
{

    // check if this is constrained to wound type
    IAPProduct *iapProduct = [IAPProduct productForIdentifier:productIdentifier
                                                       create:NO
                                         managedObjectContext:self.managedObjectContext];
    // CAUTION: we should have an IAP for productIdentifier
    if (nil == iapProduct) {
        DLog(@"Missing productIdentifier:%@ - please update our IAP products in the IAPProducts.plist and in iTunes connect", productIdentifier);
        return YES;
    }
    // has user purchased the product ?
    IAPManager *iapManager = [IAPManager sharedInstance];
    if (proceedAlways || ![iapManager isProductPurchased:iapProduct]) {
        BOOL shouldPresentPurchaseIAPViewController = NO;
        if (proceedAlways) {
            shouldPresentPurchaseIAPViewController = YES;
        } else if (nil != iapProduct.woundType) {
            // does this node has content for the current woundType ?
            if ([iapProduct.woundType.woundTypeCode isEqual:self.wound.woundType.woundTypeCode]) {
                // show IAP view controller with self as delegate - use blocks to execute for success or failure of IAP
                shouldPresentPurchaseIAPViewController = YES;
            } // else assume there is content for this node, but IAP will enhance the content, so we will still navigate to destination
        } else {
            // IAP product not restricted to wound type - must show IAP view controller
            shouldPresentPurchaseIAPViewController = YES;
        }
        if (shouldPresentPurchaseIAPViewController) {
            // present IAP view controller (don't push but present), using purchase/cancel blocks to execute when IAP purchase view controller completes
            IAPBaseViewController *viewController = nil;
            if (iapProduct.aggregatorFlag) {
                viewController = [[IAPAggregatorViewController alloc] initWithNibName:@"IAPAggregatorViewController" bundle:nil];
            } else {
                // non-aggregator view controller
                viewController = [[IAPNonConsumableViewController alloc] initWithNibName:@"IAPNonConsumableViewController" bundle:nil];
            }
            viewController.iapProduct = iapProduct;
            viewController.quantity = quantity;
            
            __weak __typeof(&*self)weakSelf = self;
            viewController.acceptHandler = ^(SKPaymentTransaction *transaction) {
                // make sure this is called on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (nil != _iapPopoverController) {
                        [_iapPopoverController dismissPopoverAnimated:YES];
                        _iapPopoverController = nil;
                        successBlock(transaction);
                    } else {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            successBlock(transaction);
                        }];
                    }
                });
            };
            viewController.declineHandler = ^{
                // make sure this is called on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.isIPadIdiom && nil != _iapPopoverController) {
                        [_iapPopoverController dismissPopoverAnimated:YES];
                        _iapPopoverController = nil;
                    } else {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            // nothing
                        }];
                    }
                });
            };
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            if ([object isKindOfClass:[WMNavigationNodeButton class]] && self.isIPadIdiom) {
                UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
                UIButton *button = (UIButton *)object;
                CGRect rect = [self.view convertRect:button.frame fromView:button.superview];
                [popoverController presentPopoverFromRect:rect
                                                   inView:self.view
                                 permittedArrowDirections:UIPopoverArrowDirectionLeft
                                                 animated:YES];
                _iapPopoverController = popoverController;
            } else if ([object isKindOfClass:[UIView class]] && self.isIPadIdiom) {
                UINavigationController *navigationController =
                [[UINavigationController alloc] initWithNavigationBarClass:[WMUnderlayNavigationBar class] toolbarClass:[WMUnderlayToolbar class]];
                [navigationController setViewControllers:@[viewController]];
                UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
                UIView *uiView = (UIView *)object;
                CGRect rect = [self.view convertRect:uiView.frame fromView:uiView.superview];
                [popoverController presentPopoverFromRect:rect
                                                   inView:self.view
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
                _iapPopoverController = popoverController;
            } else {
                [self presentViewController:navigationController animated:YES completion:^{
                    // nothing
                }];
            }
            return NO;
        }
    }
    // return YES to indicate that user should proceed to destination
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return nil;
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	return nil;
}

- (NSArray *)fetchedResultsControllerAffectedStores
{
    return nil;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
	return nil;
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
	return nil;
}

- (NSString *)fetchedResultsControllerCacheName
{
	return nil;
}

- (void)updateFetchRequest:(NSFetchRequest *)request
{
    
}

- (NSFetchRequest *)fetchRequestForFetchedResultsController
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:self.fetchedResultsControllerEntityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	// set predicate
	fetchRequest.predicate = self.fetchedResultsControllerPredicate;
    // restrict to stores
    [fetchRequest setAffectedStores:self.fetchedResultsControllerAffectedStores];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:40];
    // Edit the sort key as appropriate.
    [fetchRequest setSortDescriptors:self.fetchedResultsControllerSortDescriptors];
    // update for possible NSDictionaryResultType
    [self updateFetchRequest:fetchRequest];
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (nil != _fetchedResultsController) {
		return _fetchedResultsController;
	}
	// else
	if (0 == [self.fetchedResultsControllerEntityName length]) {
		return nil;
	}
	// else
    NSFetchRequest *fetchRequest = [self fetchRequestForFetchedResultsController];
    // Edit the section name key path and cache name if appropriate - nil for section name key path means "no sections".
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																	 managedObjectContext:self.managedObjectContext
																	   sectionNameKeyPath:self.fetchedResultsControllerSectionNameKeyPath
																				cacheName:self.fetchedResultsControllerCacheName];
    if (fetchRequest.resultType == NSManagedObjectResultType) {
        _fetchedResultsController.delegate = self;
    }
	NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        [WMUtilities logError:error];
    }
	[self performSelector:@selector(fetchedResultsControllerDidFetch) withObject:nil afterDelay:0.0];
	return _fetchedResultsController;
}

- (void)fetchedResultsControllerDidFetch
{
//    if ([self.fetchedResultsController.fetchedObjects count] == 0 && self.activeTableView == self.tableView) {
//        [self refreshTable];
//    }
}

- (void)nilFetchedResultsController
{
    _fetchedResultsController = nil;
}

- (void)refetchDataForCoreTableView
{
    _fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (void)refetchDataForTableView
{
    _fetchedResultsController = nil;
    [self.activeTableView reloadData];
}

- (NSArray *)ffQuery
{
    return nil;
}

- (id)aggregator
{
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.activeTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    // adjust for view controller
    sectionIndex = [self sectionIndexFetchedResultsControllerToTable:sectionIndex];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.activeTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.activeTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    // adjust for view controller
    indexPath = [self indexPathFetchedResultsControllerToTable:indexPath];
    newIndexPath = [self indexPathFetchedResultsControllerToTable:newIndexPath];

    UITableView *tableView = self.activeTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.activeTableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark - IndexPath Adjustments

- (NSIndexPath *)indexPathTableToFetchedResultsController:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (NSIndexPath *)indexPathFetchedResultsControllerToTable:(NSIndexPath *)indexPath
{
	return  indexPath;
}

- (NSUInteger)sectionIndexFetchedResultsControllerToTable:(NSUInteger)sectionIndex
{
	return sectionIndex;
}

- (NSUInteger)sectionIndexTableToFetchedResultsController:(NSUInteger)sectionIndex
{
	return sectionIndex;
}

@end

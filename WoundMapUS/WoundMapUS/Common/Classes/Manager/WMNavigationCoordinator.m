//
//  WMNavigationCoordinator.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMNavigationCoordinator.h"
#import "WMBaseViewController.h"
#import "WMUserDefaultsManager.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementValue.h"
#import "WMWoundMeasurement.h"
#import "WMUserDefaultsManager.h"
#import "CoreDataHelper.h"
#import "WMPolicyManager.h"
#import "WMUserDefaultsManager.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

NSString *const kPatientChangedNotification = @"PatientChangedNotification";
NSString *const kWoundChangedNotification = @"WoundChangedNotification";
NSString *const kWoundPhotoChangedNotification = @"WoundPhotoChangedNotification";
NSString *const kWoundWillDeleteNotification = @"WoundWillDeleteNotification";
NSString *const kWoundPhotoAddedNotification = @"WoundPhotoAddedNotification";
NSString *const kWoundPhotoWillDeleteNotification = @"WoundPhotoWillDeleteNotification";
NSString *const kNavigationStageChangedNotification = @"NavigationStageChangedNotification";
NSString *const kNavigationTrackChangedNotification = @"NavigationTrackChangedNotification";

@interface WMNavigationCoordinator ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) WMUserDefaultsManager *userDefaultsManager;

@property (readonly, nonatomic) WMParticipant *participant;

@property (strong, nonatomic) WMWoundMeasurementValue *woundMeasurementValueWidth;
@property (strong, nonatomic) WMWoundMeasurementValue *woundMeasurementValueLength;
@property (strong, nonatomic) WMWoundMeasurementValue *woundMeasurementValueDepth;
@property (readonly, nonatomic) WMWoundMeasurement *underminingTunnelingWoundMeasurement;

@property (readonly, nonatomic) WMTransformPhotoViewController *transformPhotoViewController;
@property (readonly, nonatomic) WMPhotoScaleViewController *photoScaleViewController;
@property (readonly, nonatomic) WMPhotoMeasureViewController *photoMeasureViewController;
@property (readonly, nonatomic) WMPhotoDepthViewController *photoDepthViewController;
@property (readonly, nonatomic) WMUndermineTunnelViewController *undermineTunnelViewController;

@property (nonatomic) BOOL exitingWoundMeasurement;                                         // exiting measurement

@end

@implementation WMNavigationCoordinator

+ (WMNavigationCoordinator *)sharedInstance
{
    static WMNavigationCoordinator *_SharedInstance = nil;
    if (nil == _SharedInstance) {
        _SharedInstance = [[WMNavigationCoordinator alloc] init];
    }
    return _SharedInstance;
}

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
    return self.coreDataHelper.context;
}

- (WMUserDefaultsManager *)userDefaultsManager
{
    return [WMUserDefaultsManager sharedInstance];
}

- (WMParticipant *)participant
{
    return self.appDelegate.participant;
}

#pragma mark - Core

- (void)clearPatientCache
{
    _patient = nil;
    _wound = nil;
    _woundPhoto = nil;
    _woundMeasurementValueWidth = nil;
    _woundMeasurementValueLength = nil;
    _woundMeasurementValueDepth  = nil;
}

- (void)setPatient:(WMPatient *)patient
{
    WM_ASSERT_MAIN_THREAD;
    if ([_patient isEqual:patient]) {
        return;
    }
    // else
    [self clearPatientCache];
    _patient = patient;
    // save user defaults
    if ([patient.ffUrl length] > 0) {
        self.userDefaultsManager.lastPatientId = patient.ffUrl;
    }
    if (nil != _patient) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangedNotification object:[_patient objectID]];
    }
}

- (void)createPatient:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMObjectCallback)completionHandler
{
    WMPatient *patient = [WMPatient MR_createInContext:managedObjectContext];
    WMParticipant *participant = self.participant;
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    patient.participant = participant;
    patient.team = participant.team;
    patient.stage = [self.navigationTrack initialStage];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ffm createPatient:patient ff:ff completionHandler:^(NSError *error, id object) {
        completionHandler(error, object);
    }];
}

- (void)deletePatient:(WMPatient *)patient completionHandler:(dispatch_block_t)completionHandler
{
    if ([patient isEqual:_patient]) {
        _patient = nil;
    }
    if (patient.ffUrl) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
        [ffm deletePatient:_patient ff:ff completionHandler:^(NSError *error) {
            completionHandler();
        }];
    } else {
        completionHandler();
    }
}

- (void)setWound:(WMWound *)wound
{
    WM_ASSERT_MAIN_THREAD;
    if ([_wound isEqual:wound]) {
        return;
    }
    // else
    _wound = wound;
    if (nil != _wound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWoundChangedNotification object:[_wound objectID]];
    }
}

- (WMWound *)lastWoundForPatient
{
    if (nil == _patient) {
        return nil;
    }
    // else
    WMWound *wound = nil;
    NSString *ffUrl = _patient.ffUrl;
    NSString *woundFFURL = [[WMUserDefaultsManager sharedInstance] lastWoundFFURLOnDeviceForPatientFFURL:ffUrl];
    if ([woundFFURL length] > 0) {
        wound = [WMWound woundForPatient:_patient woundFFURL:woundFFURL];
    }
    if (nil == wound) {
        wound = _patient.lastActiveWound;
    }
    return wound;
}

- (WMWound *)selectLastWoundForPatient
{
    WMWound *wound = self.lastWoundForPatient;
    if (nil == wound) {
        return nil;
    }
    // else
    self.wound = wound;
    return wound;
}

- (void)setWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    WM_ASSERT_MAIN_THREAD;
    if ([_woundPhoto isEqual:woundPhoto]) {
        return;
    }
    // else
    _woundPhoto = woundPhoto;
    if (nil != _woundPhoto) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWoundPhotoChangedNotification object:[_woundPhoto objectID]];
    }
}

- (WMNavigationTrack *)navigationTrack
{
    WM_ASSERT_MAIN_THREAD;
    WMNavigationTrack *navigationTrack = self.patient.stage.track;
    if (nil == navigationTrack) {
        navigationTrack = [[WMUserDefaultsManager sharedInstance] defaultNavigationTrack:self.managedObjectContext];
    }
    return navigationTrack;
}

- (void)setNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    WM_ASSERT_MAIN_THREAD;
    NSAssert(nil != navigationTrack, @"Do not set navigationTrack to nil");
    BOOL patientNavigationTrackDidChange = NO;
    [[WMUserDefaultsManager sharedInstance] setDefaultNavigationTrackFFURL:navigationTrack.ffUrl];
    WMPatient *patient = self.patient;
    if (nil != patient) {
        WMNavigationTrack *patientNavigationTrack = patient.stage.track;
        if (![patientNavigationTrack isEqual:navigationTrack]) {
            patient.stage = navigationTrack.initialStage;
            patientNavigationTrackDidChange = YES;
        }
    }
    if (patientNavigationTrackDidChange) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationTrackChangedNotification object:[navigationTrack objectID]];
    }
}

- (WMNavigationStage *)navigationStage
{
    WM_ASSERT_MAIN_THREAD;
    return self.patient.stage;
}

- (void)setNavigationStage:(WMNavigationStage *)navigationStage
{
    WM_ASSERT_MAIN_THREAD;
    NSAssert(nil != navigationStage, @"Do not set navigationStage to nil");
    WMPatient *patient = self.patient;
    if (nil != patient) {
        WMNavigationStage *patientNavigationStage = patient.stage;
        if (![patientNavigationStage isEqual:navigationStage]) {
            patient.stage = navigationStage;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationStageChangedNotification object:[navigationStage objectID]];
        }
    }
}

- (WMWoundMeasurementValue *)woundMeasurementValueWidth
{
    if (nil == _woundMeasurementValueWidth) {
        if (nil != self.woundPhoto) {
            WMWoundMeasurementGroup *group = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto];
            _woundMeasurementValueWidth = group.measurementValueWidth;
        }
    }
    return _woundMeasurementValueWidth;
}

- (WMWoundMeasurementValue *)woundMeasurementValueLength
{
    if (nil == _woundMeasurementValueLength) {
        if (nil != self.woundPhoto) {
            WMWoundMeasurementGroup *group = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto];
            _woundMeasurementValueLength = group.measurementValueLength;
        }
    }
    return _woundMeasurementValueLength;
}

- (WMWoundMeasurementValue *)woundMeasurementValueDepth
{
    if (nil == _woundMeasurementValueDepth) {
        if (nil != self.woundPhoto) {
            WMWoundMeasurementGroup *group = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto];
            _woundMeasurementValueDepth = group.measurementValueDepth;
        }
    }
    return _woundMeasurementValueDepth;
}

- (WMWoundMeasurement *)underminingTunnelingWoundMeasurement
{
    return [WMWoundMeasurement underminingTunnelingWoundMeasurement:[self.woundPhoto managedObjectContext]];
}

#pragma mark - View Controllers

- (WMTransformPhotoViewController *)transformPhotoViewController
{
    WMTransformPhotoViewController *transformPhotoViewController = [[WMTransformPhotoViewController alloc] initWithNibName:@"WMTransformPhotoViewController" bundle:nil];
    transformPhotoViewController.delegate = self;
    return transformPhotoViewController;
}

- (WMPhotoScaleViewController *)photoScaleViewController
{
    WMPhotoScaleViewController *photoScaleViewController = [[WMPhotoScaleViewController alloc] initWithNibName:@"WMPhotoScaleViewController" bundle:nil];
    photoScaleViewController.delegate = self;
    return photoScaleViewController;
}

- (WMPhotoMeasureViewController *)photoMeasureViewController
{
    WMPhotoMeasureViewController *photoMeasureViewController = [[WMPhotoMeasureViewController alloc] initWithNibName:@"WMPhotoMeasureViewController" bundle:nil];
    photoMeasureViewController.delegate = self;
    return photoMeasureViewController;
}

- (WMPhotoDepthViewController *)photoDepthViewController
{
    WMPhotoDepthViewController *photoDepthViewController = [[WMPhotoDepthViewController alloc] initWithNibName:@"WMPhotoDepthViewController" bundle:nil];
    photoDepthViewController.delegate = self;
    return photoDepthViewController;
}

- (WMUndermineTunnelViewController *)undermineTunnelViewController
{
    WMUndermineTunnelViewController *undermineTunnelViewController = [[WMUndermineTunnelViewController alloc] initWithNibName:@"WMUndermineTunnelViewController" bundle:nil];
    undermineTunnelViewController.delegate = self;
    return undermineTunnelViewController;
}

#pragma mark - Wound Measurements

- (void)viewController:(WMBaseViewController *)viewController beginMeasurementsForWoundPhoto:(WMWoundPhoto *)woundPhoto addingPhoto:(BOOL)addingPhoto
{
    // make sure the navigation bar is showing
    [viewController.navigationController setNavigationBarHidden:NO];
    self.state = addingPhoto ? NavigationCoordinatorStateMeasureNewPhoto:NavigationCoordinatorStateMeasureExistingPhoto;
    self.exitingWoundMeasurement = NO;
    self.woundPhoto = woundPhoto;
    BOOL isIPadIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (isIPadIdiom) {
        // subclass will finish
        return;
    }
    // else
    self.initialMeasurePhotoViewController = viewController;
    // adjust image or scale
    [viewController hideProgressView];
    if ([woundPhoto.wound hasPreviousWoundPhoto:woundPhoto]) {
        // adjust image
        WMTransformPhotoViewController *transformPhotoViewController = self.transformPhotoViewController;
        switch (self.state) {
            case NavigationCoordinatorStateAuthenticating:
            case NavigationCoordinatorStatePasscode:
            case NavigationCoordinatorStateInitialized: {
                // nothing
                break;
            }
            case NavigationCoordinatorStateMeasureNewPhoto: {
                [viewController.navigationController pushViewController:transformPhotoViewController animated:YES];
                break;
            }
            case NavigationCoordinatorStateMeasureExistingPhoto: {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:transformPhotoViewController];
                [viewController presentViewController:navigationController animated:YES completion:^{
                    // nothing
                }];
                break;
            }
        }
    } else {
        // set photo scale
        WMPhotoScaleViewController *photoScaleViewController = self.photoScaleViewController;
        switch (self.state) {
            case NavigationCoordinatorStateAuthenticating:
            case NavigationCoordinatorStatePasscode:
            case NavigationCoordinatorStateInitialized: {
                // nothing
                break;
            }
            case NavigationCoordinatorStateMeasureNewPhoto: {
                [viewController.navigationController pushViewController:photoScaleViewController animated:YES];
                break;
            }
            case NavigationCoordinatorStateMeasureExistingPhoto: {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoScaleViewController];
                [viewController presentViewController:navigationController animated:YES completion:^{
                    // nothing
                }];
                break;
            }
        }
    }
}

- (void)cancelWoundMeasurementNavigation:(UIViewController *)viewController
{
    if (nil == _initialMeasurePhotoViewController) {
        // already cancelled
        return;
    }
    // clear caches for all view controllers
    BOOL isIPadIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    NSArray *viewControllers = viewController.navigationController.viewControllers;
    SEL selector = @selector(clearAllReferences);
    [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:selector]) {
            SuppressPerformSelectorLeakWarning([obj performSelector:selector]);
            *stop = YES;
        }
    }];
    switch (self.state) {
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {
            // nothing
            break;
        }
        case NavigationCoordinatorStateMeasureNewPhoto: {
            // post notification that a task has finished
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kMeasurePhotoNode)];
            [viewController.navigationController popToViewController:self.initialMeasurePhotoViewController animated:NO];
            break;
        }
        case NavigationCoordinatorStateMeasureExistingPhoto: {
            // post notification that a task has finished
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:@(kMeasurePhotoNode)];
            if (isIPadIdiom) {
                [viewController.navigationController popToViewController:self.initialMeasurePhotoViewController animated:NO];
            } else {
                [self.initialMeasurePhotoViewController dismissViewControllerAnimated:NO completion:^{
                    // nothing
                }];
            }
            break;
        }
    }
    [self purgeMemoryAfterMeasurement];
}

- (void)purgeMemoryAfterMeasurement
{
    // check for empty dimensions
    if (nil != _woundMeasurementValueWidth && [_woundMeasurementValueWidth.value length] == 0) {
        _woundMeasurementValueWidth.group = nil;
        _woundMeasurementValueWidth.woundMeasurement = nil;
        [self.managedObjectContext deleteObject:_woundMeasurementValueWidth];
        _woundMeasurementValueWidth = nil;
    }
    if (nil != _woundMeasurementValueLength && [_woundMeasurementValueLength.value length] == 0) {
        _woundMeasurementValueLength.group = nil;
        _woundMeasurementValueLength.woundMeasurement = nil;
        [self.managedObjectContext deleteObject:_woundMeasurementValueLength];
        _woundMeasurementValueLength = nil;
    }
    if (nil != _woundMeasurementValueDepth && [_woundMeasurementValueDepth.value length] == 0) {
        _woundMeasurementValueDepth.group = nil;
        _woundMeasurementValueDepth.woundMeasurement = nil;
        [self.managedObjectContext deleteObject:_woundMeasurementValueDepth];
        _woundMeasurementValueDepth = nil;
    }
    // wait for notification that document has saved
    self.exitingWoundMeasurement = YES;
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        // nothing more
        if (error) {
            [WMUtilities logError:error];
        }
    }];
}

#pragma mark - Delete

- (void)deleteWound:(WMWound *)wound
{
    BOOL deletingCurrentWound = (_wound == wound);
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWoundWillDeleteNotification object:wound];
    [wound.patient removeWoundsObject:wound];
    [managedObjectContext deleteObject:wound];
    if (deletingCurrentWound) {
        [self selectLastWoundForPatient];
    }
}

- (void)deleteWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    [woundPhoto.wound removePhotosObject:woundPhoto];
    [managedObjectContext deleteObject:woundPhoto];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWoundPhotoWillDeleteNotification object:woundPhoto];
}

#pragma mark - TransformPhotoViewControllerDelegate

- (void)tranformPhotoViewController:(WMTransformPhotoViewController *)viewController didTransformPhoto:(WMWoundPhoto *)woundPhoto
{
    switch (self.state) {
        case NavigationCoordinatorStateMeasureExistingPhoto:
        case NavigationCoordinatorStateMeasureNewPhoto: {
            // set photo scale
            WMPhotoScaleViewController *photoScaleViewController = self.photoScaleViewController;
            [viewController.navigationController pushViewController:photoScaleViewController animated:YES];
            break;
        }
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {
            [viewController clearAllReferences];
            break;
        }
    }
}

- (void)tranformPhotoViewControllerDidCancel:(WMTransformPhotoViewController *)viewController
{
    switch (self.state) {
        case NavigationCoordinatorStateMeasureExistingPhoto:
        case NavigationCoordinatorStateMeasureNewPhoto: {
            [self cancelWoundMeasurementNavigation:viewController];
            break;
        }
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {
            [viewController clearAllReferences];
            break;
        }
    }
}

#pragma mark - PhotoScaleViewControllerDelegate

- (void)photoScaleViewController:(WMPhotoScaleViewController *)viewController didSetPointsPerCentimeter:(CGFloat)pointsPerCentimeter
{
    switch (self.state) {
        case NavigationCoordinatorStateMeasureExistingPhoto:
        case NavigationCoordinatorStateMeasureNewPhoto: {
            // now measure
            WMPhotoMeasureViewController *photoMeasureViewController = self.photoMeasureViewController;
            photoMeasureViewController.pointsPerCentimeter = pointsPerCentimeter;
            [viewController.navigationController pushViewController:photoMeasureViewController animated:YES];
            break;
        }
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {
            [viewController clearAllReferences];
            break;
        }
    }
}

- (void)photoScaleViewControllerDidCancel:(WMPhotoScaleViewController *)viewController
{
    switch (self.state) {
        case NavigationCoordinatorStateMeasureExistingPhoto:
        case NavigationCoordinatorStateMeasureNewPhoto: {
            [self cancelWoundMeasurementNavigation:viewController];
            break;
        }
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {
            [viewController clearAllReferences];
            break;
        }
    }
}

#pragma mark - PhotoMeasureViewControllerDelegate

- (void)photoMeasureViewControllerDelegate:(WMPhotoMeasureViewController *)viewController length:(NSDecimalNumber *)length width:(NSDecimalNumber *)width
{
    switch (self.state) {
        case NavigationCoordinatorStateMeasureExistingPhoto:
        case NavigationCoordinatorStateMeasureNewPhoto: {
            // update measurement
            self.woundMeasurementValueWidth.value = [width stringValue];
            self.woundMeasurementValueLength.value = [length stringValue];
            // now measure
            [viewController.navigationController pushViewController:self.photoDepthViewController animated:YES];
            break;
        }
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {
            [viewController clearAllReferences];
            break;
        }
    }
}

#pragma mark - PhotoDepthViewControllerDelegate

- (void)photoDepthViewControllerDelegate:(WMPhotoDepthViewController *)viewController depth:(NSDecimalNumber *)depth
{
    switch (self.state) {
        case NavigationCoordinatorStateMeasureExistingPhoto:
        case NavigationCoordinatorStateMeasureNewPhoto: {
            // update measurement
            self.woundMeasurementValueDepth.value = [depth stringValue];
            // now enter undermining & tunneling
            WMUndermineTunnelViewController *undermineTunnelViewController = self.undermineTunnelViewController;
            undermineTunnelViewController.woundMeasurementGroup = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto];
            undermineTunnelViewController.showCancelButton = NO;
            [viewController.navigationController pushViewController:undermineTunnelViewController animated:YES];
            break;
        }
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {
            [viewController clearAllReferences];
            break;
        }
    }
}

#pragma mark - UndermineTunnelViewControllerDelegate

// TODO - move to area view controller
- (void)undermineTunnelViewControllerDidDone:(WMUndermineTunnelViewController *)viewController
{
    [self cancelWoundMeasurementNavigation:viewController];
}

- (void)undermineTunnelViewControllerDidCancel:(WMUndermineTunnelViewController *)viewController
{
    [self cancelWoundMeasurementNavigation:viewController];
}

@end

//
//  WMNavigationCoordinator.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMNavigationCoordinator.h"
#import "WMBaseViewController.h"
#import "WMWelcomeToWoundMapViewController.h"
#import "MBProgressHUD.h"
#import "WMUserDefaultsManager.h"
#import "WMTeam.h"
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
#import "IAPManager.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "Faulter.h"
#import "NSObject+performBlockAfterDelay.h"
#import "WCAppDelegate.h"

#define kCurrentPatientDeletedAlertViewTag 1000

NSString *const kPatientChangedNotification = @"PatientChangedNotification";
NSString *const kPatientRefreshingFromCloudNotification = @"PatientRefreshingFromCloudNotification";
NSString *const kPatientNavigationDataChangedOnDeviceNotification = @"PatientNavigationDataChangedOnDeviceNotification";
NSString *const kWoundChangedNotification = @"WoundChangedNotification";
NSString *const kWoundPhotoChangedNotification = @"WoundPhotoChangedNotification";
NSString *const kWoundWillDeleteNotification = @"WoundWillDeleteNotification";
NSString *const kWoundPhotoAddedNotification = @"WoundPhotoAddedNotification";
NSString *const kWoundPhotoWillDeleteNotification = @"WoundPhotoWillDeleteNotification";
NSString *const kRequestToBrowsePhotosNotification = @"RequestToBrowsePhotosNotification";
NSString *const kTransformControllerDidInstallNotification = @"TransformControllerDidInstallNotification";
NSString *const kTransformControllerDidUninstallNotification = @"TransformControllerDidUninstallNotification";
NSString *const kNavigationStageChangedNotification = @"NavigationStageChangedNotification";
NSString *const kNavigationTrackChangedNotification = @"NavigationTrackChangedNotification";
NSString *const kRespondedToReferralNotification = @"RespondedToReferralNotification";
NSString *const kAcquiredWoundPhotosNotification = @"AcquiredWoundPhotosNotification";
NSString *const kBackendDeletedObjectIDs = @"BackendDeletedObjectIDs";

@interface WMNavigationCoordinator () <UIAlertViewDelegate>

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

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    FFHttpMethodCompletion onUpdateCompletion = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };

    __weak __typeof(&*self)weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kAcquiredWoundPhotosNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      // refault
                                                      [Faulter faultObjectWithIDs:[notification object] inContext:[NSManagedObjectContext MR_defaultContext]];
                                                  }];
    // watch for objects deleted by another device or team member from back end
    [[NSNotificationCenter defaultCenter] addObserverForName:kBackendDeletedObjectIDs
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      NSArray *objectIDs = [notification object];
                                                      if ([objectIDs containsObject:[_patient objectID]]) {
                                                          [weakSelf clearPatientCache];
                                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Patient Deleted"
                                                                                                              message:@"The current patient has been deleted by another team member."
                                                                                                             delegate:self
                                                                                                    cancelButtonTitle:@"Continue"
                                                                                                    otherButtonTitles:nil];
                                                          alertView.tag = kCurrentPatientDeletedAlertViewTag;
                                                          [alertView show];
                                                      }
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kPatientNavigationDataChangedOnDeviceNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                          WMPatient *patient = notification.object;
                                                          WMFatFractal *ff = [WMFatFractal sharedInstance];
                                                          IAPManager *iapManager = [IAPManager sharedInstance];
                                                          NSString *deviceId = [iapManager getIAPDeviceGuid];
                                                          patient.lastUpdatedOnDeviceId = deviceId;
                                                          [ff updateObj:patient onComplete:onUpdateCompletion onOffline:onUpdateCompletion];
                                                  }];

    return self;
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
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    // else update patient status
    if (_patient && !_patient.isDeleting) {
        [_patient updatePatientStatusMessages];
        [[_patient managedObjectContext] MR_saveToPersistentStoreAndWait];
        FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
        };
        [ff updateObj:_patient onComplete:onComplete onOffline:onComplete];
    }
    [self clearPatientCache];
    _patient = patient;
    if (nil != _patient) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangedNotification object:[_patient objectID]];
        // attempt to set a wound
        self.wound = self.lastWoundForPatient;
    }
    if ([patient.ffUrl length] > 0) {
//        IAPManager *iapManager = [IAPManager sharedInstance];
//        NSString *deviceId = [iapManager getIAPDeviceGuid];
        // we need to get the groups and values
//        [ff getObjFromUri:[NSString stringWithFormat:@"%@/(lastUpdatedOnDeviceId ne '%@')?depthRef=1&depthGb=2", patient.ffUrl, deviceId] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        // update UI to show that patient data is refreshing from cloud
        [[NSNotificationCenter defaultCenter] postNotificationName:kPatientRefreshingFromCloudNotification object:[_patient objectID]];
        [ff getObjFromUri:[NSString stringWithFormat:@"%@?depthRef=1&depthGb=2", patient.ffUrl] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (nil != object) {
                if (error) {
                    // may not receive any data
                    [WMUtilities logError:error];
                }
                [[patient managedObjectContext] MR_saveToPersistentStoreAndWait];
                [weakSelf.userDefaultsManager setLastPatientFFURL:patient.ffUrl forUserGUID:weakSelf.appDelegate.participant.guid];
                [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangedNotification object:[_patient objectID]];
            }
        }];
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
    patient.createdOnDeviceId = [[IAPManager sharedInstance] getIAPDeviceGuid];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ffm createPatient:patient ff:ff completionHandler:^(NSError *error, id object) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        completionHandler(error, object);
    }];
}

- (BOOL)canEditPatientOnDevice:(WMPatient *)patient
{
    if (nil == patient) {
        patient = self.patient;
    }
    if (nil == patient) {
        return NO;
    }
    // else must purchase IAP to edit a patient on a device that it was not created on
    IAPManager *iapManager = [IAPManager sharedInstance];
    if (self.participant.team) {
        return YES;
    }
    // else
    return [patient.createdOnDeviceId isEqualToString:[iapManager getIAPDeviceGuid]];
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
        __weak __typeof(&*self)weakSelf = self;
        [[WMUserDefaultsManager sharedInstance] setLastWoundFFURLOnDevice:wound.ffUrl forPatientFFURL:self.patient.ffUrl];
        // save user defaults
        if ([wound.ffUrl length] > 0) {
            // we need to get the groups and values
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            [ff getObjFromUri:[NSString stringWithFormat:@"%@?depthRef=1&depthGb=2", wound.ffUrl] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    // may not receive any data
                    [WMUtilities logError:error];
                }
                [[wound managedObjectContext] MR_saveToPersistentStoreAndWait];
                // set last wound photo
                weakSelf.woundPhoto = wound.lastWoundPhoto;
                [[NSNotificationCenter defaultCenter] postNotificationName:kWoundChangedNotification object:[wound objectID]];
            }];
        }
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
    // navigationTrack may not be on back end if participant team nil
    if (nil == navigationTrack.ffUrl) {
        navigationTrack.ffUrl = @"No Team";
        [[navigationTrack managedObjectContext] MR_saveToPersistentStoreAndWait];
    }
    [[WMUserDefaultsManager sharedInstance] setDefaultNavigationTrackFFURL:navigationTrack.ffUrl];
    WMPatient *patient = self.patient;
    if (nil != patient) {
        WMNavigationTrack *patientNavigationTrack = patient.stage.track;
        if (![patientNavigationTrack isEqual:navigationTrack]) {
            self.navigationStage = navigationTrack.initialStage;
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
    WMNavigationStage *stage = self.patient.stage;
    // bug fix should make this unnecessary
    if (nil == stage) {
        stage = self.navigationTrack.initialStage;
        self.patient.stage = stage;
        [[WMFatFractal sharedInstance] updateObj:self.patient];
    }
    return stage;
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
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                }
                [[patient managedObjectContext] MR_saveToPersistentStoreAndWait];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationStageChangedNotification object:[navigationStage objectID]];
            };
            [ff updateObj:patient
               onComplete:completionHandler
                onOffline:completionHandler];
        }
    }
}

- (WMWoundMeasurementValue *)woundMeasurementValueWidth
{
    if (nil == _woundMeasurementValueWidth) {
        if (nil != self.woundPhoto) {
            WMWoundMeasurementGroup *group = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto create:NO];
            _woundMeasurementValueWidth = group.measurementValueWidth;
        }
    }
    return _woundMeasurementValueWidth;
}

- (WMWoundMeasurementValue *)woundMeasurementValueLength
{
    if (nil == _woundMeasurementValueLength) {
        if (nil != self.woundPhoto) {
            WMWoundMeasurementGroup *group = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto create:NO];
            _woundMeasurementValueLength = group.measurementValueLength;
        }
    }
    return _woundMeasurementValueLength;
}

- (WMWoundMeasurementValue *)woundMeasurementValueDepth
{
    if (nil == _woundMeasurementValueDepth) {
        if (nil != self.woundPhoto) {
            WMWoundMeasurementGroup *group = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto create:NO];
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
    undermineTunnelViewController.saveToStoreOnSave = YES;
    return undermineTunnelViewController;
}

#pragma mark - Wound Measurements

- (void)viewController:(UIViewController *)viewController beginMeasurementsForWoundPhoto:(WMWoundPhoto *)woundPhoto addingPhoto:(BOOL)addingPhoto
{
    // update wound measurements from back end
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    WMErrorCallback block = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (--counter) {
            return;
        }
        // else proceed
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideHUDForView:viewController.view animated:NO];
        [viewController.navigationController setNavigationBarHidden:NO];
        weakSelf.state = addingPhoto ? NavigationCoordinatorStateMeasureNewPhoto:NavigationCoordinatorStateMeasureExistingPhoto;
        weakSelf.woundPhoto = woundPhoto;
        BOOL isIPadIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        if (isIPadIdiom) {
            // subclass will finish
            return;
        }
        // else
        weakSelf.initialMeasurePhotoViewController = viewController;
        // adjust image or scale
        if ([woundPhoto.wound hasPreviousWoundPhoto:woundPhoto]) {
            // adjust image
            WMTransformPhotoViewController *transformPhotoViewController = weakSelf.transformPhotoViewController;
            switch (weakSelf.state) {
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
            WMPhotoScaleViewController *photoScaleViewController = weakSelf.photoScaleViewController;
            switch (weakSelf.state) {
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
        [MBProgressHUD hideAllHUDsForView:viewController.view animated:NO];
    };
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    ++counter;
    ++counter;
    ++counter;
    [ffm updateGrabBags:@[WMWoundRelationships.photos]
             aggregator:woundPhoto.wound
                     ff:[WMFatFractal sharedInstance]
      completionHandler:^(NSError *error) {
          block(error);
          // make sure we have downloaded previous photo
          WMWoundPhoto *referenceWoundPhoto = [woundPhoto.wound referenceWoundPhoto:woundPhoto];
          if ([woundPhoto.wound hasPreviousWoundPhoto:woundPhoto] && referenceWoundPhoto.thumbnail == nil && !woundPhoto.photoDeletedPerTeamPolicy) {
              [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnail]] executeAsyncWithBlock:^(FFReadResponse *response) {
                  NSData *photoData = [response rawResponseData];
                  if (response.httpResponse.statusCode > 300) {
                      DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                  }
                  referenceWoundPhoto.thumbnail = [[UIImage alloc] initWithData:photoData];
                  block(response.error);
              }];
              [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnailLarge]] executeAsyncWithBlock:^(FFReadResponse *response) {
                  NSData *photoData = [response rawResponseData];
                  if (response.httpResponse.statusCode > 300) {
                      DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                  }
                  referenceWoundPhoto.thumbnailLarge = [[UIImage alloc] initWithData:photoData];
                  block(response.error);
              }];
          } else {
              --counter;
              block(error);
          }
      }];
    ++counter;
    [ffm updateGrabBags:@[WMWoundPhotoRelationships.measurementGroups]
             aggregator:woundPhoto
                     ff:[WMFatFractal sharedInstance]
      completionHandler:block];
}

- (void)cancelWoundMeasurementNavigation:(UIViewController *)viewController
{
    if (nil == _initialMeasurePhotoViewController) {
        // already cancelled
        return;
    }
    BOOL isIPadIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
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
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (nil != _woundMeasurementValueWidth && [_woundMeasurementValueWidth.value length] == 0) {
        _woundMeasurementValueWidth.group = nil;
        _woundMeasurementValueWidth.woundMeasurement = nil;
        [managedObjectContext deleteObject:_woundMeasurementValueWidth];
        _woundMeasurementValueWidth = nil;
    }
    if (nil != _woundMeasurementValueLength && [_woundMeasurementValueLength.value length] == 0) {
        _woundMeasurementValueLength.group = nil;
        _woundMeasurementValueLength.woundMeasurement = nil;
        [managedObjectContext deleteObject:_woundMeasurementValueLength];
        _woundMeasurementValueLength = nil;
    }
    if (nil != _woundMeasurementValueDepth && [_woundMeasurementValueDepth.value length] == 0) {
        _woundMeasurementValueDepth.group = nil;
        _woundMeasurementValueDepth.woundMeasurement = nil;
        [managedObjectContext deleteObject:_woundMeasurementValueDepth];
        _woundMeasurementValueDepth = nil;
    }
    NSSet *deletedObjects = managedObjectContext.deletedObjects;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    for (id object in deletedObjects) {
        // don't think I need to remove from grab bags
        [ff deleteObj:object
           onComplete:completionHandler
            onOffline:completionHandler];
    }
    [ff updateObj:self.woundPhoto];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

#pragma mark - Delete

- (void)deletePatient:(WMPatient *)patient completionHandler:(dispatch_block_t)completionHandler
{
    // mark that we are deleting patient
    patient.isDeleting = YES;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    BOOL deleteFromBackend = (nil != patient.ffUrl);
    if ([patient isEqual:_patient]) {
        self.patient = nil;
    }
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    __block NSInteger counter = 0;
    FFHttpMethodCompletion httpMethodCompletion = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (object) {
            [ff forgetObj:object];
        }
        if (counter == 0 || --counter == 0) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            completionHandler();
        }
    };
    [managedObjectContext MR_deleteObjects:@[patient]];
    [managedObjectContext processPendingChanges];
    if (deleteFromBackend) {
        ++counter;
        [ff deleteObj:patient.consultantGroup onComplete:httpMethodCompletion];
        NSSet *deletedObjects = managedObjectContext.deletedObjects;
        counter += [deletedObjects count];
        for (id object in deletedObjects) {
            [ff deleteObj:object onComplete:httpMethodCompletion];
        }
    }
}

- (void)deleteWoundFromBackEnd:(WMWound *)wound
{
    // delete from back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSError *error = nil;
    [ff grabBagRemove:self.wound from:self.patient grabBagName:WMPatientRelationships.wounds error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
    if (self.wound.locationValue) {
        [ff deleteObj:self.wound.locationValue error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }
    if ([self.wound.positionValues count]) {
        for (WMWoundPositionValue *positionValue in self.wound.positionValues) {
            [ff deleteObj:positionValue error:&error];
            if (error) {
                [WMUtilities logError:error];
            }
        }
    }
    [ff deleteObj:self.wound error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
}

- (void)deleteWound:(WMWound *)wound
{
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    BOOL deletingCurrentWound = (_wound == wound);
    BOOL deleteFromBackend = (nil != wound.ffUrl);
    if (deleteFromBackend) {
        ffm.processDeletesOnNSManagedObjectContextObjectsDidChangeNotification = YES;
    }
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWoundWillDeleteNotification object:wound];
    [wound.patient removeWoundsObject:wound];
    [managedObjectContext MR_deleteObjects:@[wound]];
    [managedObjectContext processPendingChanges];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    ffm.processDeletesOnNSManagedObjectContextObjectsDidChangeNotification = NO;
    if (deletingCurrentWound) {
        [self selectLastWoundForPatient];
    }
}

- (void)deleteWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    [woundPhoto.wound removePhotosObject:woundPhoto];
    if (_woundPhoto == woundPhoto) {
        _woundPhoto = nil;
    }
    [managedObjectContext MR_deleteObjects:@[woundPhoto]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWoundPhotoWillDeleteNotification object:woundPhoto];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kCurrentPatientDeletedAlertViewTag) {
        [self.appDelegate signOut];
        UINavigationController *navigationController = self.appDelegate.initialViewController;
        [UIView transitionWithView:self.appDelegate.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.appDelegate.window.rootViewController = navigationController;
                        } completion:^(BOOL finished) {
                            // nothing
                        }];
    }
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
            [[self.woundPhoto managedObjectContext] MR_saveToPersistentStoreAndWait];
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
            undermineTunnelViewController.woundMeasurementGroup = [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self.woundPhoto create:NO];
            undermineTunnelViewController.showCancelButton = NO;
            [viewController.navigationController pushViewController:undermineTunnelViewController animated:YES];
            break;
        }
        case NavigationCoordinatorStateAuthenticating:
        case NavigationCoordinatorStatePasscode:
        case NavigationCoordinatorStateInitialized: {

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

#pragma mark - UINavigationControllerDelegate

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController
{
    return UIInterfaceOrientationPortrait;
}


@end

//
//  WMNavigationCoordinator.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTransformPhotoViewController.h"
#import "WMPhotoScaleViewController.h"
#import "WMPhotoMeasureViewController.h"
#import "WMPhotoDepthViewController.h"
#import "WMUndermineTunnelViewController.h"
#import "WMFatFractalManager.h"

extern NSString *const kPatientChangedNotification;
extern NSString *const kWoundChangedNotification;
extern NSString *const kWoundPhotoChangedNotification;
extern NSString *const kWoundWillDeleteNotification;
extern NSString *const kWoundPhotoAddedNotification;
extern NSString *const kWoundPhotoWillDeleteNotification;
extern NSString *const kRequestToBrowsePhotosNotification;
extern NSString *const kTransformControllerDidInstallNotification;
extern NSString *const kTransformControllerDidUninstallNotification;
extern NSString *const kNavigationTrackChangedNotification;
extern NSString *const kNavigationStageChangedNotification;
extern NSString *const kRespondedToReferralNotification;

@class WMBaseViewController;
@class WMPatient, WMWound, WMWoundPhoto;
@class WMNavigationTrack, WMNavigationStage;

typedef enum {
    NavigationCoordinatorStateInitialized = 0,
    NavigationCoordinatorStateAuthenticating = 1,
    NavigationCoordinatorStatePasscode = 2,
    NavigationCoordinatorStateMeasureNewPhoto = 3,
    NavigationCoordinatorStateMeasureExistingPhoto = 4,
} NavigationCoordinatorState;

@interface WMNavigationCoordinator : NSObject <TransformPhotoViewControllerDelegate, PhotoScaleViewControllerDelegate, PhotoMeasureViewControllerDelegate, PhotoDepthViewControllerDelegate, UndermineTunnelViewControllerDelegate, UINavigationControllerDelegate>

+ (WMNavigationCoordinator *)sharedInstance;

@property (readonly, nonatomic) WCAppDelegate *appDelegate;

@property (strong, nonatomic) WMPatient *patient;           // active patient
@property (strong, nonatomic) WMWound *wound;               // active wound
@property (strong, nonatomic) WMWoundPhoto *woundPhoto;     // active woundPhoto

@property (nonatomic) WMNavigationTrack *navigationTrack;   // active track
@property (nonatomic) WMNavigationStage *navigationStage;   // active stage

- (void)clearPatientCache;

- (void)createPatient:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMObjectCallback)completionHandler;
- (void)deletePatient:(WMPatient *)patient completionHandler:(dispatch_block_t)completionHandler;
- (BOOL)canEditPatientOnDevice:(WMPatient *)patient;

@property (nonatomic) NavigationCoordinatorState state;
@property (strong, nonatomic) UIViewController *initialMeasurePhotoViewController;

@property (readonly, nonatomic) WMWound *lastWoundForPatient;
- (WMWound *)selectLastWoundForPatient;
- (void)deleteWoundFromBackEnd:(WMWound *)wound;
- (void)deleteWound:(WMWound *)wound;

- (void)viewController:(UIViewController *)viewController beginMeasurementsForWoundPhoto:(WMWoundPhoto *)woundPhoto addingPhoto:(BOOL)addingPhoto;
- (void)cancelWoundMeasurementNavigation:(UIViewController *)viewController;
- (void)deleteWoundPhoto:(WMWoundPhoto *)woundPhoto;

@end

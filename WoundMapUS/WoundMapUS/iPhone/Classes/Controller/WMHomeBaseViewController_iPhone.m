//
//  WMHomeBaseViewController_iPhone.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMHomeBaseViewController_iPhone.h"
#import "WMPatientTableViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMWoundDetailViewController.h"
#import "WMSelectWoundViewController.h"
#import "WMSkinAssessmentGroupViewController.h"
#import "WMBradenScaleViewController.h"
#import "WMMedicationGroupViewController.h"
#import "WMDevicesViewController.h"
#import "WMPsychoSocialGroupViewController.h"
#import "WMWoundMeasurementGroupViewController.h"
#import "WMPhotosContainerViewController.h"
#import "WMPatientSummaryContainerViewController.h"
#import "WMNavigationNodeButton.h"
#import "WMNavigationCoordinator.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WMMedicationGroup.h"
#import "WMDeviceGroup.h"
#import "WMPsychoSocialGroup.h"
#import "WMPhotoManager.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"

@interface WMHomeBaseViewController_iPhone ()

@end

@implementation WMHomeBaseViewController_iPhone

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
    // Do any additional setup after loading the view from its nib.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.navigationPatientWoundContainerView.drawTopLine = NO;
    self.navigationPatientWoundContainerView.deltaY = 0.0;
    // update navigation bar
    [self updateNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // else restore transform for patient wound stage cell
    [self.navigationPatientWoundContainerView resetState:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseViewController

- (void)registerForNotifications
{
    [super registerForNotifications];
}

#pragma mark - Actions

// the action depends on parentNavigationNode
- (IBAction)takePatientPhotoAction:(id)sender
{
    if (nil == self.parentNavigationNode) {
        // we are home, so take photo
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.takePatientPhotoViewController];
        navigationController.delegate = self.appDelegate;
        [self presentViewController:navigationController animated:YES completion:^{
            // nothing
        }];
    }
    [super takePatientPhotoAction:sender];
}

#pragma mark - Model/View synchronization

#pragma mark - View Controllers

- (WMPhotosContainerViewController *)photosContainerViewController
{
    return [[WMPhotosContainerViewController alloc] initWithNibName:@"WMPhotosContainerViewController" bundle:nil];
}

#pragma mark - Navigation

- (void)navigateToPatientDetail:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPatientDetailViewController *patientDetailViewController = self.patientDetailViewController;
    patientDetailViewController.newPatientFlag = NO;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:patientDetailViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToPatientDetailViewControllerForNewPatient:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPatientDetailViewController *patientDetailViewController = self.patientDetailViewController;
    patientDetailViewController.newPatientFlag = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:patientDetailViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToSelectPatient:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPatientTableViewController *patientTableViewController = self.patientTableViewController;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:patientTableViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing more
    }];
}

- (void)navigateToWoundDetail:(WMNavigationNodeButton *)navigationNodeButton
{
    WMWoundDetailViewController *woundDetailViewController = self.woundDetailViewController;
    woundDetailViewController.newWoundFlag = NO;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:woundDetailViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToWoundDetailViewControllerForNewWound:(WMNavigationNodeButton *)navigationNodeButton
{
    WMWoundDetailViewController *woundDetailViewController = self.woundDetailViewController;
    woundDetailViewController.newWoundFlag = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:woundDetailViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToSelectWound:(WMNavigationNodeButton *)navigationNodeButton
{
    WMSelectWoundViewController *selectWoundViewController = self.selectWoundViewController;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectWoundViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToSkinAssessmentForNavigationNode:(WMNavigationNodeButton *)navigationNodeButton
{
    WMSkinAssessmentGroupViewController *skinAssessmentGroupViewController = self.skinAssessmentGroupViewController;
    skinAssessmentGroupViewController.navigationNode = navigationNodeButton.navigationNode;
    skinAssessmentGroupViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:skinAssessmentGroupViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)navigateToBradenScaleAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.bradenScaleViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToMedicationAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMMedicationGroupViewController *medicationsViewController = self.medicationsViewController;
    medicationsViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medicationsViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToDeviceAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMDevicesViewController *devicesViewController = self.devicesViewController;
    devicesViewController.deviceGroup = [WMDeviceGroup activeDeviceGroup:self.patient];
    devicesViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:devicesViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToPsychoSocialAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPsychoSocialGroupViewController *viewController = self.psychoSocialGroupViewController;
    viewController.psychoSocialGroup = [WMPsychoSocialGroup activePsychoSocialGroup:self.patient];
    viewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)navigateToSkinAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMSkinAssessmentGroupViewController *skinAssessmentGroupViewController = self.skinAssessmentGroupViewController;
    skinAssessmentGroupViewController.navigationNode = navigationNodeButton.navigationNode;
    skinAssessmentGroupViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:skinAssessmentGroupViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)navigateToTakePhoto:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPhotoManager * photoManager = [WMPhotoManager sharedInstance];
    photoManager.delegate = self;
    [self presentViewController:photoManager.imagePickerController animated:YES completion:^{
        if (photoManager.shouldUseCameraForNextPhoto) {
            [photoManager setupImagePicker];
        }
    }];
}

- (void)navigateToWoundAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMWoundMeasurementGroupViewController *woundMeasurementGroupViewController = self.woundMeasurementGroupViewController;
    woundMeasurementGroupViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:woundMeasurementGroupViewController];
    navigationController.delegate = self.appDelegate;
    [self.navigationController presentViewController:navigationController
                                            animated:YES
                                          completion:^{
                                              // nothing
                                          }];
}

- (void)navigateToWoundTreatment:(WMNavigationNodeButton *)navigationNodeButton
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.woundTreatmentGroupsViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)navigateToBrowsePhotos:(id)sender
{
    // Browse Photos - inactive if no photos
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:self.photosContainerViewController]
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)navigateToViewGraphs:(id)sender
{
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:self.plotSelectDatasetViewController]
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)navigateToPatientSummary:(id)sender
{
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:self.patientSummaryContainerViewController]
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

- (void)navigateToShare:(id)sender
{
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:self.shareViewController]
                       animated:YES
                     completion:^{
                         // nothing
                     }];
}

#pragma mark - PatientTableViewControllerDelegate

- (void)patientTableViewController:(WMPatientTableViewController *)viewController didSelectPatient:(WMPatient *)patient
{
    // update our reference to current patient
    if (nil != patient) {
        self.appDelegate.navigationCoordinator.patient = patient;
    }
    __weak __typeof(viewController) weakViewController = viewController;
    [self dismissViewControllerAnimated:YES completion:^{
        // new document will update the UI from registerForNotifications
        [weakViewController clearAllReferences];
    }];
}

- (void)patientTableViewControllerDidCancel:(WMPatientTableViewController *)viewController
{
    __weak __typeof(viewController) weakViewController = viewController;
    [self dismissViewControllerAnimated:YES completion:^{
        // new document will update the UI from registerForNotifications
        [weakViewController clearAllReferences];
    }];
}

#pragma mark - PatientDetailViewControllerDelegate

- (void)patientDetailViewControllerDidUpdatePatient:(WMPatientDetailViewController *)viewController
{
    __block WMPatient *patient = viewController.patient;
    // clear memory
    [viewController clearAllReferences];
    // update our reference to current patient
    self.appDelegate.navigationCoordinator.patient = patient;
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
    NSManagedObjectContext *managedObjectContext = patient.managedObjectContext;
    // make sure the track/stage is set
    if (nil == patient.stage) {
        // set stage to initial for default clinical setting
        WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:managedObjectContext];
        WMNavigationStage *navigationStage = navigationTrack.initialStage;
        patient.stage = navigationStage;
    }
    [self showProgressViewWithMessage:@"Saving patient record"];
    __weak __typeof(self) weakSelf = self;
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            [weakSelf hideProgressView];
            // update backend

        }
    }];
}

- (void)patientDetailViewControllerDidCancelUpdate:(WMPatientDetailViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
    // clear memory
    [viewController clearAllReferences];
    // confirm that we have a clean moc
    NSAssert1(![self.managedObjectContext hasChanges], @"self.managedObjectContext has changes", self.managedObjectContext);
}

#pragma mark - SelectWoundViewControllerDelegate

- (void)selectWoundController:(WMSelectWoundViewController *)viewController didSelectWound:(WMWound *)wound
{
    [super selectWoundController:viewController didSelectWound:wound];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)selectWoundControllerDidCancel:(WMSelectWoundViewController *)viewController
{
    [super selectWoundControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - WoundDetailViewControllerDelegate

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didUpdateWound:(WMWound *)wound
{
    [super woundDetailViewController:viewController didUpdateWound:wound];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)woundDetailViewControllerDidCancelUpdate:(WMWoundDetailViewController *)viewController
{
    [super woundDetailViewControllerDidCancelUpdate:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didDeleteWound:(WMWound *)wound
{
    [super woundDetailViewController:viewController didDeleteWound:wound];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - BradenScaleDelegate

- (void)bradenScaleControllerDidFinish:(WMBradenScaleViewController *)viewController
{
    [super bradenScaleControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - MedicationGroupViewControllerDelegate

- (void)medicationGroupViewControllerDidSave:(WMMedicationGroupViewController *)viewController
{
    [super medicationGroupViewControllerDidSave:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)medicationGroupViewControllerDidCancel:(WMMedicationGroupViewController *)viewController
{
    [super medicationGroupViewControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - DevicesViewControllerDelegate

- (void)devicesViewControllerDidSave:(WMDevicesViewController *)viewController
{
    [super devicesViewControllerDidSave:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)devicesViewControllerDidCancel:(WMDevicesViewController *)viewController
{
    [super devicesViewControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - PsychoSocialGroupViewControllerDelegate

- (void)psychoSocialGroupViewControllerDidFinish:(WMPsychoSocialGroupViewController *)viewController
{
    [super psychoSocialGroupViewControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)psychoSocialGroupViewControllerDidCancel:(WMPsychoSocialGroupViewController *)viewController
{
    [super psychoSocialGroupViewControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - SkinAssessmentGroupViewControllerDelegate

- (void)skinAssessmentGroupViewControllerDidSave:(WMSkinAssessmentGroupViewController *)viewController
{
    [super skinAssessmentGroupViewControllerDidSave:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)skinAssessmentGroupViewControllerDidCancel:(WMSkinAssessmentGroupViewController *)viewController
{
    [super skinAssessmentGroupViewControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - TakePatientPhotoDelegate

- (void)takePatientPhotoViewControllerDidFinish:(WMTakePatientPhotoViewController *)viewController
{
    [super takePatientPhotoViewControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - OverlayViewControllerDelegate

- (void)photoManager:(WMPhotoManager *)photoManager didCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata
{
    [super photoManager:photoManager didCaptureImage:image metadata:metadata];
    switch (self.photoAcquisitionState) {
        case PhotoAcquisitionStateNone: {
            break;
        }
        case PhotoAcquisitionStateAcquireWoundPhoto: {
            // tear down interface
            [self dismissViewControllerAnimated:YES completion:^{
                self.photoAcquisitionState = PhotoAcquisitionStateNone;
            }];
            break;
        }
        case PhotoAcquisitionStateAcquirePatientPhoto: {
            // process image in background using self.photoManager scaleAndCenterPatientPhoto:(UIImage *)photo rect:(CGRect)rect
            // tear down interface
            [self dismissViewControllerAnimated:YES completion:^{
                self.photoAcquisitionState = PhotoAcquisitionStateNone;
            }];
            break;
        }
    }
}

- (void)photoManagerDidCancelCaptureImage:(WMPhotoManager *)photoManager
{
    // tear down interface
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing more
    }];
}

#pragma mark - WoundTreatmentGroupsDelegate

- (void)woundTreatmentGroupsViewControllerDidFinish:(WMWoundTreatmentGroupsViewController *)viewController
{
    [super woundTreatmentGroupsViewControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)woundTreatmentGroupsViewControllerDidCancel:(WMWoundTreatmentGroupsViewController *)viewController
{
    [super woundTreatmentGroupsViewControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController
{
    [super woundMeasurementGroupViewControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController
{
    [super woundMeasurementGroupViewControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - PlotViewControllerDelegate

- (void)plotViewControllerDidCancel:(WMBaseViewController *)viewController
{
    [super plotViewControllerDidCancel:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)plotViewControllerDidFinish:(WMBaseViewController *)viewController
{
    [super plotViewControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - PatientSummaryContainerDelegate

- (void)patientSummaryContainerViewControllerDidFinish:(WMPatientSummaryContainerViewController *)viewController
{
    [super patientSummaryContainerViewControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - ShareViewControllerDelegate

- (void)shareViewControllerDidFinish:(WMShareViewController *)viewController
{
    [super shareViewControllerDidFinish:viewController];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

@end

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
#import "User.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WMMedicationGroup.h"
#import "WMDeviceGroup.h"
#import "WMPhotoManager.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import <objc/runtime.h>

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

#pragma mark - Model/View synchronization

- (void)updateNavigationBar
{
    [super updateNavigationBar];
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
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:navigationController] animated:YES completion:^{
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
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:navigationController] animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToBradenScaleAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.bradenScaleViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:navigationController] animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToMedicationAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMMedicationGroupViewController *medicationsViewController = self.medicationsViewController;
    medicationsViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    medicationsViewController.medicationGroup = [WMMedicationGroup activeMedicationGroup:self.managedObjectContext];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medicationsViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:navigationController] animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToDeviceAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMDevicesViewController *devicesViewController = self.devicesViewController;
    devicesViewController.deviceGroup = [WMDeviceGroup activeDeviceGroup:self.managedObjectContext];
    devicesViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    devicesViewController.medicationGroup = [WMMedicationGroup activeMedicationGroup:self.managedObjectContext];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medicationsViewController];
    navigationController.delegate = self.appDelegate;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:navigationController] animated:YES completion:^{
        // nothing
    }];
}

- (void)navigateToPsychoSocialAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPsychoSocialGroupViewController *viewController = self.psychoSocialGroupViewController;
    viewController.psychoSocialGroup = [WMPsychoSocialGroup activePsychoSocialGroup:self.managedObjectContext];
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
    [self presentViewController:self.photoManager.imagePickerController animated:YES completion:^{
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
    CoreDataHelper *coreDataHelper = self.coreDataHelper;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    // make sure the track/stage is set
    if (nil == patient.stage) {
        // set stage to initial for default clinical setting
        WMNavigationTrack *navigationTrack = [self.userDefaultsManager defaultNavigationTrack:managedObjectContext persistentStore:store];
        WMNavigationStage *navigationStage = navigationTrack.initialStage;
        patient.stage = navigationStage;
    }
    [self showProgressViewWithMessage:@"Saving patient record"];
    __weak __typeof(self) weakSelf = self;
    [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
        [WMUtilities logError:error];
        // make sure the user (sm_owner) has access via the consultants relationship
        User *user = nil;
        if([coreDataHelper.stackMobClient isLoggedIn]) {
            user = [User userForUsername:weakSelf.appDelegate.stackMobUsername
                    managedObjectContext:managedObjectContext persistentStore:store];
            WMParticipant *participant = weakSelf.appDelegate.participant;
            WMPatientConsultant *patientConsultant = [WMPatientConsultant patientConsultantForPatient:patient
                                                                                           consultant:user
                                                                                          participant:participant
                                                                                               create:YES
                                                                                 managedObjectContext:managedObjectContext
                                                                                      persistentStore:store];
            patientConsultant.acquiredFlagValue = NO;
        }
        [weakSelf.tableView reloadData];
        // save again
        [self.coreDataHelper saveContextWithCompletionHandler:^(NSError *error) {
            [WMUtilities logError:error];
            [weakSelf hideProgressView];
        }];
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

@end

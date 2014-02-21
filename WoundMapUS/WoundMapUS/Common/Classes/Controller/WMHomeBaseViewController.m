//
//  WMHomeBaseViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMHomeBaseViewController.h"
#import "WMPolicyEditorViewController.h"
#import "WMCarePlanTableViewCell.h"
#import "WMPatient.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"

@interface WMHomeBaseViewController () <PolicyEditorDelegate>

@property (readonly, nonatomic) WMPolicyEditorViewController *policyEditorViewController;
@property (nonatomic) BOOL removingTrackAndOrStageCells;

- (IBAction)editPoliciesAction:(id)sender;

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
    NSInteger row = 2;
    if (!self.shouldShowSelectTrackTableViewCell) {
        --row;
    }
    if (!self.shouldShowSelectStageTableViewCell) {
        --row;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

#pragma mark - Actions

- (IBAction)selectInitialStageAction:(id)sender
{
    self.patient.stage = [WCNavigationStage initialStageForTrack:self.patient.stage.track
                                            managedObjectContext:self.managedObjectContext
                                                 persistentStore:nil];
}

- (IBAction)selectFollowupStageAction:(id)sender
{
    self.patient.stage = [WCNavigationStage followupStageForTrack:self.patient.stage.track
                                             managedObjectContext:self.managedObjectContext
                                                  persistentStore:nil];
}

- (IBAction)selectDischargeStageAction:(id)sender
{
    self.patient.stage = [WCNavigationStage dischargeStageForTrack:self.patient.stage.track
                                              managedObjectContext:self.managedObjectContext
                                                   persistentStore:nil];
}

- (IBAction)selectPatientAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    [self navigateToSelectPatient:navigationNodeButton];
}

- (IBAction)editPatientAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    [self navigateToPatientDetail:navigationNodeButton];
}

- (IBAction)addPatientAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    // create patient
    [self navigateToPatientDetailViewControllerForNewPatient:navigationNodeButton];
}

- (IBAction)selectWoundAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    [self navigateToSelectWound:navigationNodeButton];
}

- (IBAction)editWoundAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    [self navigateToWoundDetailForWound:self.wound newWoundFlag:NO button:navigationNodeButton];
}

- (IBAction)addWoundAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    self.appDelegate.wound = [WCWound createWoundForPatient:self.patient];
    [self navigateToWoundDetailForWound:self.wound newWoundFlag:YES button:navigationNodeButton];
}

- (IBAction)woundsAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    [self navigateToWounds:navigationNodeButton];
}

- (IBAction)chooseTrackAction:(id)sender
{
    [self navigateToNavigationTracks];
}

- (IBAction)selectStageAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
            // initial (admit)
            self.navigationCoordinator.navigationStage = [WCNavigationStage initialStageForTrack:self.navigationCoordinator.navigationTrack
                                                                            managedObjectContext:self.document.managedObjectContext
                                                                                 persistentStore:nil];
            break;
        }
        case 1: {
            // follow-up
            self.navigationCoordinator.navigationStage = [WCNavigationStage followupStageForTrack:self.navigationCoordinator.navigationTrack
                                                                             managedObjectContext:self.document.managedObjectContext
                                                                                  persistentStore:nil];
            break;
        }
        case 2: {
            // discharge
            self.navigationCoordinator.navigationStage = [WCNavigationStage dischargeStageForTrack:self.navigationCoordinator.navigationTrack
                                                                              managedObjectContext:self.document.managedObjectContext
                                                                                   persistentStore:nil];
            break;
        }
    }
}

- (IBAction)riskAssessmentAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    WCNavigationNode *navigationNode = navigationNodeButton.navigationNode;
    if ([navigationNode.subnodes count] > 0) {
        // this should have subnodes, just being anal
        [self animateNavigationNodeButtonIntoCompassCenter:navigationNodeButton];
    }
}

- (IBAction)homeAction:(id)sender
{
    self.parentNavigationNode = self.parentNavigationNode.parentNode;
}

- (IBAction)bradenScaleAction:(id)sender
{
    NSAssert([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [self.policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
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
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"sender:%@ must be NavigationNodeButton", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [self.policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
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
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [self.policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToDeviceAssessment:navigationNodeButton];
}

- (IBAction)psycoSocialAssessmentAction:(id)sender
{
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [self.policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToPsychoSocialAssessment:navigationNodeButton];
}

- (IBAction)skinAssessmentAction:(id)sender
{
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [self.policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToSkinAssessmentForNavigationNode:navigationNodeButton];
}

- (IBAction)photoAction:(id)sender
{
    NSAssert1([sender isKindOfClass:[WMNavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    WMNavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    WCNavigationNode *navigationNode = navigationNodeButton.navigationNode;
    [self navigateToPhoto:navigationNode];
}

- (IBAction)handleSwipeNavigationNodeControl:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NavigationNodeButton *button = (NavigationNodeButton *)gestureRecognizer.view;
    WCNavigationNode *navigationNode = button.navigationNode;
    NavigationNodeIdentifier navigationNodeIdentifier = navigationNode.navigationNodeIdentifier;
    switch (navigationNodeIdentifier) {
        case kTakePhotoNode: {
            self.photoManager.usePhotoLibraryForNextPhoto = YES;
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
    [self navigateToTakePhoto:(NavigationNodeButton *)sender];
}

// the action depends on parentNavigationNode
- (IBAction)takePatientPhotoAction:(id)sender
{
    if (nil == self.parentNavigationNode) {
        // we are home, so take photo
        self.photoAcquisitionState = PhotoAcquisitionStateAcquirePatientPhoto;
        if (self.isIPadIdiom) {
            UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.takePatientPhotoViewController];
            UIButton *button = self.compassView.patientPhotoView;
            CGRect rect = [self.view convertRect:button.frame fromView:button.superview];
            [popoverController presentPopoverFromRect:rect
                                               inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
        } else {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.takePatientPhotoViewController];
            navigationController.delegate = self.appDelegate;
            [self presentViewController:navigationController animated:YES completion:^{
                // nothing
            }];
        }
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
    NSAssert1([sender isKindOfClass:[NavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    NavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [self.policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
    [self navigateToWoundAssessment:navigationNodeButton];
}

- (IBAction)woundTreatmentAction:(id)sender
{
    NSAssert1([sender isKindOfClass:[NavigationNodeButton class]], @"Expected sender to be NavigationNodeButton: %@", sender);
    NavigationNodeButton *navigationNodeButton = (NavigationNodeButton *)sender;
    navigationNodeButton.recentlyClosedCount = [self.policyManager closeExpiredRecords:navigationNodeButton.navigationNode];
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
    [self navigateToBrowsePhotos];
}

- (IBAction)viewGraphsAction:(id)sender
{
    [self navigateToViewGraphs:sender];
}

- (IBAction)viewPatientSummaryAction:(id)sender
{
    [self navigateToPatientSummary];
}

- (IBAction)shareAction:(id)sender
{
    [self navigateToShare];
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

#pragma mark - BaseViewController

- (void)registerForNotifications
{
    [super registerForNotifications];
    // adjust when task completes
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kTaskDidCompleteNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [weakSelf performSelector:@selector(reloadNavigationUI) withObject:nil afterDelay:0.0];
                                                                }];
    [self.persistantObservers addObject:observer];
    // pull down our popover
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                                 object:nil
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *notification) {
                                                                 if (weakSelf.isIPadIdiom) {
                                                                     UIViewController *viewController = [weakSelf.navigationNodePopoverController contentViewController];
                                                                     if (nil != viewController) {
                                                                         if ([viewController isKindOfClass:[UINavigationController class]]) {
                                                                             UINavigationController *navigationController = (UINavigationController *)viewController;
                                                                             viewController = navigationController.topViewController;
                                                                         }
                                                                         if ([viewController isKindOfClass:[BaseViewController class]]) {
                                                                             BaseViewController *baseViewController = (BaseViewController *)viewController;
                                                                             [baseViewController clearAllReferences];
                                                                         }
                                                                         [weakSelf.navigationNodePopoverController dismissPopoverAnimated:NO];
                                                                     } else {
                                                                         // check for presented view controller
                                                                         __block UIViewController *viewController = weakSelf.appDelegate.window.rootViewController.presentedViewController;
                                                                         if (nil != viewController) {
                                                                             [viewController dismissViewControllerAnimated:NO completion:^{
                                                                                 if ([viewController isKindOfClass:[UINavigationController class]]) {
                                                                                     UINavigationController *navigationController = (UINavigationController *)viewController;
                                                                                     viewController = navigationController.topViewController;
                                                                                 }
                                                                                 if ([viewController isKindOfClass:[BaseViewController class]]) {
                                                                                     BaseViewController *baseViewController = (BaseViewController *)viewController;
                                                                                     [baseViewController clearAllReferences];
                                                                                 }
                                                                             }];
                                                                         }
                                                                     }
                                                                 } else {
                                                                     __block UIViewController *viewController = weakSelf.appDelegate.window.rootViewController.presentedViewController;
                                                                     if (nil != viewController) {
                                                                         [viewController dismissViewControllerAnimated:NO completion:^{
                                                                             if ([viewController isKindOfClass:[UINavigationController class]]) {
                                                                                 UINavigationController *navigationController = (UINavigationController *)viewController;
                                                                                 viewController = navigationController.topViewController;
                                                                             }
                                                                             if ([viewController isKindOfClass:[BaseViewController class]]) {
                                                                                 BaseViewController *baseViewController = (BaseViewController *)viewController;
                                                                                 [baseViewController clearAllReferences];
                                                                             }
                                                                         }];
                                                                     }
                                                                 }
                                                             }];
    [self.persistantObservers addObject:observer];
}

- (void)clearDataCache
{
    [super clearDataCache];
    _parentNavigationNode = nil;
    [self clearNavigationCache];
    [self.compassView updateForPatient:nil];
}

#pragma mark - ChooseTrackDelegate

- (void)chooseTrackViewController:(ChooseTrackViewController *)viewController didChooseNavigationTrack:(WCNavigationTrack *)navigationTrack
{
    self.navigationCoordinator.navigationTrack = navigationTrack;
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

- (void)chooseTrackViewControllerDidCancel:(ChooseTrackViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - ChooseStageDelegate

- (WCNavigationTrack *)navigationTrack
{
    return self.navigationCoordinator.navigationTrack;
}

- (WCNavigationStage *)navigationStage
{
    return self.navigationCoordinator.navigationStage;
}

- (void)chooseStageViewController:(ChooseStageViewController *)chooseStageViewController didSelectNavigationStage:(WCNavigationStage *)navigationStage
{
    self.navigationCoordinator.navigationStage = navigationStage;
    [self.navigationController popViewControllerAnimated:YES];
    [chooseStageViewController clearAllReferences];
}

- (void)chooseStageViewControllerDidCancel:(ChooseStageViewController *)chooseStageViewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [chooseStageViewController clearAllReferences];
}

#pragma mark - PatientTableViewControllerDelegate

- (void)patientTableViewController:(PatientTableViewController *)viewController didSelectDocument:(NSString *)documentName
{
    // navigation coordinator will automatically set its document property from viewController
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        [viewController clearAllReferences];
        _navigationNodePopoverController = nil;
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            // new document will update the UI from registerForNotifications
            [weakViewController clearAllReferences];
        }];
    }
}

- (void)patientTableViewControllerDidCancel:(PatientTableViewController *)viewController
{
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        [viewController clearAllReferences];
        _navigationNodePopoverController = nil;
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            // new document will update the UI from registerForNotifications
            [weakViewController clearAllReferences];
        }];
    }
}

#pragma mark - PatientDetailViewControllerDelegate

- (void)patientDetailViewControllerDidUpdatePatient:(PatientDetailViewController *)viewController
{
    // clear memory
    [viewController clearAllReferences];
    // PatientDetailViewController has updated the patient in the document - move data to index store
    [self.documentManager saveDocument:self.document];
    // if this is a new patient, update stage to initial workup
    if (viewController.isNewPatient) {
        self.navigationCoordinator.navigationStage = self.navigationCoordinator.navigationTrack.initialStage;
    }
    __weak __typeof(viewController) weakViewController = viewController;
    __weak __typeof(self) weakSelf = self;
    if (self.isIPadIdiom) {
        if (weakViewController.isNewPatient) {
            [weakSelf updateUIForDocumentWoundStageChanged];
        } else {
            [weakSelf.navigationPatientWoundContainerView updateContentForDocument];
        }
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakViewController.isNewPatient) {
                [weakSelf updateUIForDocumentWoundStageChanged];
            } else {
                [weakSelf.navigationPatientWoundContainerView updateContentForDocument];
            }
        }];
    }
    self.state = PatientSelectedStateNone;
    // synchronize the index store
    [self.patientManager updateIndexPatientFromDocumentPatient:self.patient];
}

- (void)patientDetailViewControllerDidCancelUpdate:(PatientDetailViewController *)viewController
{
    if (viewController.isNewPatient) {
        [self showProgressViewWithMessage:@"Creating Patient Record"];
        [self.documentManager deleteDocument:viewController.patient.documentName];
    }
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // clear memory
        [viewController clearAllReferences];
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakViewController clearAllReferences];
        }];
    }
    self.state = PatientSelectedStateNone;
}

#pragma mark - SelectWoundViewControllerDelegate

- (void)selectWoundController:(SelectWoundViewController *)viewController didSelectWound:(WCWound *)wound
{
    [self.documentManager saveDocument:viewController.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // clear memory
        [viewController clearAllReferences];
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakViewController clearAllReferences];
        }];
    }
    self.wound = wound;
}

- (void)selectWoundControllerDidCancel:(SelectWoundViewController *)viewController
{
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // clear memory
        [viewController clearAllReferences];
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakViewController clearAllReferences];
        }];
    }
}

#pragma mark - WoundDetailViewControllerDelegate

- (void)woundDetailViewControllerDidUpdateWound:(WoundDetailViewController *)viewController
{
    // save
    [self.documentManager saveDocument:viewController.document];
    // clear memory
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
    // update UI
    [self.navigationPatientWoundContainerView updateContentForDocument];
    [self.tableView reloadData];
}

- (void)woundDetailViewControllerDidCancelUpdate:(WoundDetailViewController *)viewController
{
    if (viewController.isNewWound) {
        [self.navigationCoordinator deleteWound:viewController.wound];
        self.wound = [self.navigationCoordinator selectLastWound];
    }
    [self.documentManager saveDocument:viewController.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // clear memory
        [viewController clearAllReferences];
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakViewController clearAllReferences];
        }];
    }
    // reload table
    [self.tableView reloadData];
}

- (void)woundDetailViewController:(WoundDetailViewController *)viewController didDeleteWound:(WCWound *)wound
{
    [self.navigationCoordinator deleteWound:wound];
    self.wound = [self.navigationCoordinator selectLastWound];
    [self.documentManager saveDocument:viewController.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // clear memory
        [viewController clearAllReferences];
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakViewController clearAllReferences];
        }];
    }
    // reload table
    [self.tableView reloadData];
}

#pragma mark - BradenScaleDelegate

- (void)bradenScaleControllerDidFinish:(BradenScaleViewController *)viewController
{
    [viewController clearAllReferences];
    // save in order to update dateModified
    [self.documentManager saveDocument:self.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // Braden gets saved before here, so just assume changes have been made
        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kBradenScaleNode]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // Braden gets saved before here, so just assume changes have been made
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kBradenScaleNode]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
        }];
    }
}

#pragma mark - MedicationGroupViewControllerDelegate

- (void)medicationGroupViewControllerDidSave:(MedicationGroupViewController *)viewController
{
    BOOL hasChanges = self.managedObjectContext.hasChanges;
    BOOL hasValues = [[viewController.medicationGroup medications] count] > 0;
    if (!hasValues) {
        [self.managedObjectContext deleteObject:viewController.medicationGroup];
        hasChanges = YES;
    }
    [viewController clearAllReferences];
    // save in order to update dateModified
    [self.documentManager saveDocument:self.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        if (hasChanges) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kMedicationsNode]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            if (hasChanges) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kMedicationsNode]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
            }
        }];
    }
}

- (void)medicationGroupViewControllerDidCancel:(MedicationGroupViewController *)viewController
{
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        [viewController clearAllReferences];
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakViewController clearAllReferences];
        }];
    }
}

#pragma mark - DevicesViewControllerDelegate

- (void)devicesViewControllerDidSave:(DevicesViewController *)viewController
{
    BOOL hasChanges = self.managedObjectContext.hasChanges;
    BOOL hasValues = [viewController.deviceGroup.values count] > 0;
    if (!hasValues) {
        [self.managedObjectContext deleteObject:viewController.deviceGroup];
        hasChanges = YES;
    }
    [viewController clearAllReferences];
    // save in order to update dateModified
    [self.documentManager saveDocument:self.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        if (hasChanges) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kDevicesNode]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (hasChanges) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kDevicesNode]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kRiskAssessmentNode]];
        }
    }];
}

- (void)devicesViewControllerDidCancel:(DevicesViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            weakViewController.delegate = nil;
        }];
    }
}

#pragma mark - PsychoSocialGroupViewControllerDelegate

- (void)psychoSocialGroupViewControllerDidFinish:(PsychoSocialGroupViewController *)viewController
{
    BOOL hasChanges = self.managedObjectContext.hasChanges;
    BOOL hasValues = [viewController.psychoSocialGroup.values count] > 0;
    if (!hasValues) {
        [self.managedObjectContext deleteObject:viewController.psychoSocialGroup];
        hasChanges = YES;
    }
    [viewController clearAllReferences];
    // save in order to update dateModified
    [self.documentManager saveDocument:self.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        if (hasChanges) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kPsycoSocialNode]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (hasChanges) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kPsycoSocialNode]];
        }
    }];
}

- (void)psychoSocialGroupViewControllerDidCancel:(PsychoSocialGroupViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        __weak __typeof(viewController) weakViewController = viewController;
        [self dismissViewControllerAnimated:YES completion:^{
            weakViewController.delegate = nil;
        }];
    }
}

#pragma mark - SkinAssessmentGroupViewControllerDelegate

- (void)skinAssessmentGroupViewControllerDidSave:(SkinAssessmentGroupViewController *)viewController
{
    BOOL hasChanges = self.managedObjectContext.hasChanges;
    BOOL hasValues = [viewController.skinAssessmentGroup.values count] > 0;
    if (!hasValues) {
        [self.managedObjectContext deleteObject:viewController.skinAssessmentGroup];
        hasChanges = YES;
    }
    [viewController clearAllReferences];
    // save in order to update dateModified
    [self.documentManager saveDocument:self.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // post notification if some values were added
        if (hasChanges) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kSkinAssessmentNode]];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // post notification if some values were added
            if (hasChanges) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kSkinAssessmentNode]];
            }
        }];
    }
}

- (void)skinAssessmentGroupViewControllerDidCancel:(SkinAssessmentGroupViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

#pragma mark - TakePatientPhotoDelegate

- (void)takePatientPhotoViewControllerDidFinish:(TakePatientPhotoViewController *)viewController
{
    [viewController clearAllReferences];
    [self.compassView updateForPatientPhotoProcessed];
    [self.compassView updateForDocument:self.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
    self.photoAcquisitionState = PhotoAcquisitionStateNone;
}

#pragma mark - OverlayViewControllerDelegate

- (void)photoManager:(PhotoManager *)photoManager didCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata
{
    DLog(@"image %@", NSStringFromCGSize(image.size));
    switch (self.photoAcquisitionState) {
        case PhotoAcquisitionStateNone: {
            NSAssert(NO, @"acquire photo in invalid state");
            break;
        }
        case PhotoAcquisitionStateAcquireWoundPhoto: {
            // tear down interface
            self.savingWoundPhotoFlag = YES;
            if (self.isIPadIdiom && !self.photoManager.shouldUseCameraForNextPhoto) {
                [self showProgressViewWithMessage:@"Processing Photo"];
                [_navigationNodePopoverController dismissPopoverAnimated:YES];
                _navigationNodePopoverController = nil;
                // have photoManager start the process
                WCWoundPhoto *woundPhoto = [self.photoManager processNewImage:image
                                                                     metadata:metadata
                                                                        wound:self.wound
                                                                     document:self.document];
                // save the photo now and wait for save to complete
                self.woundPhoto = woundPhoto;
                [self updateToolbar];
                [self.documentManager saveDocument:self.document];
            } else {
                __weak __typeof(self) weakSelf = self;
                [self dismissViewControllerAnimated:YES completion:^{
                    [self showProgressViewWithMessage:@"Processing Photo"];
                    // have photoManager start the process
                    WCWoundPhoto *woundPhoto = [weakSelf.photoManager processNewImage:image
                                                                             metadata:metadata
                                                                                wound:weakSelf.wound
                                                                             document:weakSelf.document];
                    // save the photo now and wait for save to complete
                    woundPhoto = (WCWoundPhoto *)[weakSelf.managedObjectContext objectWithID:[woundPhoto objectID]];
                    weakSelf.woundPhoto = woundPhoto;
                    [weakSelf updateToolbar];
                    [weakSelf.documentManager saveDocument:weakSelf.document];
                }];
            }
            break;
        }
        case PhotoAcquisitionStateAcquirePatientPhoto: {
            // process image in background using self.photoManager scaleAndCenterPatientPhoto:(UIImage *)photo rect:(CGRect)rect
            __weak __typeof(self) weakSelf = self;
            [self dismissViewControllerAnimated:YES completion:^{
                weakSelf.photoAcquisitionState = PhotoAcquisitionStateNone;
            }];
            [self.compassView updateForPatientPhotoProcessing];
            self.patient.thumbnail = image;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL success = NO;
                weakSelf.patient.thumbnail = [weakSelf.photoManager scaleAndCenterPatientPhoto:image rect:CGRectMake(0.0, 0.0, 256.0, 256.0) success:&success];
                if (success) {
                    weakSelf.patient.faceDetectionFailed = NO;
                } else {
                    weakSelf.patient.faceDetectionFailed = YES;
                }
                [weakSelf.documentManager saveDocument:weakSelf.document];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.compassView updateForPatientPhotoProcessed];
                    [weakSelf.compassView updateForDocument:weakSelf.document];
                });
                
            });
            break;
        }
    }
}

- (void)photoManagerDidCancelCaptureImage:(PhotoManager *)photoManager
{
    if (self.isIPadIdiom && !self.photoManager.shouldUseCameraForNextPhoto) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

#pragma mark - CarePlanGroupViewControllerDelegate

- (void)carePlanGroupViewControllerDidSave:(CarePlanGroupViewController *)viewController
{
    BOOL hasChanges = self.managedObjectContext.hasChanges;
    // save in order to update dateModified
    [self.documentManager saveDocument:self.document];
    [viewController clearAllReferences];
    [self dismissViewControllerAnimated:YES completion:^{
        // post notification if some values were added
        if (hasChanges) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kCarePlanNode]];
        }
    }];
}

- (void)carePlanGroupViewControllerDidCancel:(CarePlanGroupViewController *)viewController
{
    [viewController clearAllReferences];
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - WoundTreatmentGroupsDelegate

- (void)woundTreatmentGroupsViewControllerDidFinish:(WoundTreatmentGroupsViewController *)viewController
{
    [viewController clearAllReferences];
    // save in order to update dateModified
    [self.documentManager saveDocument:self.document];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
        // always update since moc is saved
        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kWoundTreatmentNode]];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // always update since moc is saved
            [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kWoundTreatmentNode]];
        }];
    }
}

- (void)woundTreatmentGroupsViewControllerDidCancel:(WoundTreatmentGroupsViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WoundMeasurementGroupViewController *)viewController
{
    [self.documentManager saveDocument:viewController.document];
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
    // notify interface of completed task
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskDidCompleteNotification object:[NSNumber numberWithInt:kWoundAssessmentNode]];
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WoundMeasurementGroupViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

#pragma mark - PlotViewControllerDelegate

- (void)plotViewControllerDidCancel:(BaseViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

- (void)plotViewControllerDidFinish:(BaseViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        // could be PlotSelectDatasetViewController, PlotConfigureGraphViewController, or PlotGraphViewController
        if ([viewController isKindOfClass:[PlotSelectDatasetViewController class]] || [viewController isKindOfClass:[PlotConfigureGraphViewController class]]) {
            [_navigationNodePopoverController dismissPopoverAnimated:YES];
            _navigationNodePopoverController = nil;
        } else if ([viewController isKindOfClass:[PlotGraphViewController class]]) {
            [self dismissViewControllerAnimated:YES completion:^{
                // nothing
            }];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
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

- (void)simpleTableViewController:(SimpleTableViewController *)simpleTableViewController didSelectValues:(NSArray *)selectedValues
{
}

- (void)simpleTableViewControllerDidCancel:(SimpleTableViewController *)simpleTableViewController
{
}

#pragma mark - PatientSummaryContainerDelegate

- (void)PatientSummaryContainerViewControllerDidFinish:(PatientSummaryContainerViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

#pragma mark - ShareViewControllerDelegate

- (void)shareViewControllerDidFinish:(ShareViewController *)viewController
{
    [viewController clearAllReferences];
    if (self.isIPadIdiom) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if we are to try again, check the status of our document
    if (alertView.tag == kFailedToCreateAndSaveDocumentAlertTag) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            return;
        }
        // else let's try to create/open a new document again
        [self addPatientAction:nil];
    }
}

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

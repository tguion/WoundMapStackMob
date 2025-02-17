//
//  WMHomeBaseViewController_iPad.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMHomeBaseViewController_iPad.h"
#import "WMWelcomeToWoundMapViewController_iPad.h"
#import "WMPatientTableViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMPhotosContainerViewController_iPad.h"
#import "WMWoundDetailViewController.h"
#import "WMSelectWoundViewController.h"
#import "WMPlotSelectDatasetViewController.h"
#import "WMPlotConfigureGraphViewController.h"
#import "WMPlotGraphViewController.h"
#import "WMNavigationPatientPhotoButton.h"
#import "WMNavigationNodeButton.h"
#import "WMUnderlayNavigationBar.h"
#import "WMUnderlayToolbar.h"
#import "WMPatient.h"
#import "WMPatientConsultant.h"
#import "WMNavigationTrack.h"
#import "TakePhotoProtocols.h"
#import "WMNavigationCoordinator.h"
#import "WMPhotoManager.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMHomeBaseViewController_iPad () <UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *navigationNodePopoverController;

- (UIPopoverController *)navigationNodePopoverControllerForContentViewController:(UIViewController *)viewController;

@end

@implementation WMHomeBaseViewController_iPad

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Controllers

- (WMWelcomeToWoundMapViewController_iPad *)welcomeToWoundMapViewController
{
    return [[WMWelcomeToWoundMapViewController_iPad alloc] initWithNibName:@"WMWelcomeToWoundMapViewController_iPad" bundle:nil];
}

- (WMPhotosContainerViewController *)photosContainerViewController
{
    return [[WMPhotosContainerViewController_iPad alloc] initWithNibName:@"WMPhotosContainerViewController_iPad" bundle:nil];
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.navigationNodeControls makeObjectsPerformSelector:@selector(setHidden:) withObject:@YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.compassView recenterNavigationControls];
    [self.navigationNodeControls makeObjectsPerformSelector:@selector(setHidden:) withObject:@NO];
    [self.compassView animateNodesIntoActivePosition];
    [self.compassView setNeedsDisplay];
}

#pragma mark - Core

- (UIPopoverController *)navigationNodePopoverControllerForContentViewController:(UIViewController *)viewController
{
    // create navigation controller
    UINavigationController* navigationController = nil;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        // already a UINavigationController
        navigationController = (UINavigationController *)viewController;
    } else {
        navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[WMUnderlayNavigationBar class] toolbarClass:[WMUnderlayToolbar class]];
        navigationController.delegate = self.appDelegate;
        [navigationController setViewControllers:@[viewController]];
    }
    
    UIPopoverController *popoverController = _navigationNodePopoverController;
    if (popoverController && popoverController.isPopoverVisible) {
        [popoverController setContentViewController:navigationController animated:YES];
        return popoverController;
    }
    
    popoverController = _navigationNodePopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    _navigationNodePopoverController.delegate = self;

    return popoverController;
}

#pragma mark - Actions

// the action depends on parentNavigationNode
- (IBAction)takePatientPhotoAction:(id)sender
{
    if (nil == self.parentNavigationNode) {
        // we are home, so take photo
        self.photoAcquisitionState = PhotoAcquisitionStateAcquirePatientPhoto;
        UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.takePatientPhotoViewController];
        UIButton *button = self.compassView.patientPhotoView;
        CGRect rect = [self.view convertRect:button.frame fromView:button.superview];
        [popoverController presentPopoverFromRect:rect
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
    [super takePatientPhotoAction:sender];

}

#pragma mark - Keyboard

- (void)observeKeyboardWillShowNotification:(NSNotification *)note
{
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)note
{
}

#pragma mark - Navigation

- (void)navigateToManageTeam:(UIBarButtonItem *)barButtonItem
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.manageTeamViewController];
    [popoverController presentPopoverFromBarButtonItem:barButtonItem
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];

}

- (void)navigateToPatientDetail:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPatientDetailViewController *patientDetailViewController = self.patientDetailViewController;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:patientDetailViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToPatientDetailViewControllerForNewPatient:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPatientDetailViewController *patientDetailViewController = self.patientDetailViewController;
    patientDetailViewController.newPatientFlag = YES;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:patientDetailViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToSelectPatient:(WMNavigationNodeButton *)navigationNodeButton
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.patientTableViewController];
    CGRect rect = [self.view convertRect:self.selectPatientButton.frame fromView:self.selectPatientButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToWoundDetail:(WMNavigationNodeButton *)navigationNodeButton
{
    WMWoundDetailViewController *woundDetailViewController = self.woundDetailViewController;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:woundDetailViewController];
    CGRect buttonRect = navigationNodeButton.frame;
    CGRect rect = [self.view convertRect:buttonRect fromView:self.addWoundButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToWoundDetailViewControllerForNewWound:(WMNavigationNodeButton *)navigationNodeButton
{
    WMWoundDetailViewController *woundDetailViewController = self.woundDetailViewController;
    woundDetailViewController.newWoundFlag = YES;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:woundDetailViewController];
    CGRect buttonRect = navigationNodeButton.frame;
    CGRect rect = [self.view convertRect:buttonRect fromView:self.addWoundButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToSelectWound:(WMNavigationNodeButton *)navigationNodeButton
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.selectWoundViewController];
    CGRect rect = [self.view convertRect:self.selectWoundButton.frame fromView:self.selectWoundButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToSkinAssessmentForNavigationNode:(WMNavigationNodeButton *)navigationNodeButton
{
    WMSkinAssessmentGroupViewController *skinAssessmentGroupViewController = self.skinAssessmentGroupViewController;
    skinAssessmentGroupViewController.navigationNode = navigationNodeButton.navigationNode;
    skinAssessmentGroupViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:skinAssessmentGroupViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToBradenScaleAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.bradenScaleViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToMedicationAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMMedicationGroupViewController *medicationsViewController = self.medicationsViewController;
    medicationsViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:medicationsViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToDeviceAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMDevicesViewController *devicesViewController = self.devicesViewController;
    devicesViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:devicesViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToPsychoSocialAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPsychoSocialGroupViewController *viewController = self.psychoSocialGroupViewController;
    viewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:viewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToNutritionAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMNutritionGroupViewController *viewController = self.nutritionGroupViewController;
    viewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:viewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToTakePhoto:(WMNavigationNodeButton *)navigationNodeButton
{
    WMPhotoManager *photoManager = [WMPhotoManager sharedInstance];
    photoManager.delegate = self;
    if (!photoManager.shouldUseCameraForNextPhoto) {
        UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:photoManager.imagePickerController];
        CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
        [popoverController presentPopoverFromRect:rect
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    } else {
        [self presentViewController:photoManager.imagePickerController animated:NO completion:^{
            if (photoManager.shouldUseCameraForNextPhoto) {
                [photoManager setupImagePicker];
            }
        }];
    }
}

- (void)navigateToWoundAssessment:(WMNavigationNodeButton *)navigationNodeButton
{
    WMWoundMeasurementGroupViewController *woundMeasurementGroupViewController = self.woundMeasurementGroupViewController;
    woundMeasurementGroupViewController.recentlyClosedCount = navigationNodeButton.recentlyClosedCount;
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:woundMeasurementGroupViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToWoundTreatment:(WMNavigationNodeButton *)navigationNodeButton
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.woundTreatmentGroupsViewController];
    CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)navigateToViewGraphs:(id)sender
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.plotSelectDatasetViewController];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [popoverController presentPopoverFromBarButtonItem:sender
                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];
    } else {
        WMNavigationNodeButton *navigationNodeButton = (WMNavigationNodeButton *)sender;
        CGRect rect = [self.view convertRect:navigationNodeButton.frame fromView:navigationNodeButton.superview];
        [popoverController presentPopoverFromRect:rect
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

- (void)navigateToPatientSummary:(id)sender
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.patientSummaryContainerViewController];
    [popoverController presentPopoverFromBarButtonItem:self.patientSummaryBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)navigateToShare:(id)sender
{
    UIPopoverController *popoverController = [self navigationNodePopoverControllerForContentViewController:self.shareViewController];
    CGRect rect = [self.view convertRect:self.shareButton.frame fromView:self.shareButton.superview];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

#pragma mark - Notification handlers

- (void)handleApplicationWillResignActiveNotification
{
    UIViewController *viewController = [_navigationNodePopoverController contentViewController];
    if (nil != viewController) {
        NSMutableArray *viewControllers = [NSMutableArray array];
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            [viewControllers addObjectsFromArray:navigationController.viewControllers];
        } else {
            [viewControllers addObject:viewController];
        }
        for (WMBaseViewController *viewController in viewControllers) {
            if ([viewController respondsToSelector:@selector(clearAllReferences)]) {
                [viewController performSelector:@selector(clearAllReferences)];
            }
        }
        [_navigationNodePopoverController dismissPopoverAnimated:NO];
        _navigationNodePopoverController = nil;
    } else {
        // check for presented view controller
        [super handleApplicationWillResignActiveNotification];
    }
}

#pragma mark - UIPopoverControllerDelegate

// Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    NSArray *viewControllers = nil;
    UIViewController *viewController = popoverController.contentViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        viewControllers = [navigationController viewControllers];
        for (UIViewController *vc in viewControllers) {
            if ([vc isKindOfClass:[WMWoundDetailViewController class]]) {
                viewController = vc;
                break;
            }
        }
    }
    if ([viewController isKindOfClass:[WMWoundDetailViewController class]]) {
        WMWoundDetailViewController *vc = (WMWoundDetailViewController *)viewController;
        if (vc.isNewWound) {
            return NO;
        }
    }
    return YES;
}

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.navigationNodePopoverController) {
        if ([popoverController.contentViewController isKindOfClass:[WMBaseViewController class]]) {
            WMBaseViewController *baseViewController = (WMBaseViewController *)popoverController.contentViewController;
            [baseViewController clearAllReferences];
        } else {
            // check
        }
        self.navigationNodePopoverController = nil;
    }
}

#pragma mark - PatientTableViewControllerDelegate

- (void)patientTableViewController:(WMPatientTableViewController *)viewController didSelectPatient:(WMPatient *)patient
{
    [super patientTableViewController:viewController didSelectPatient:patient];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}


- (void)patientTableViewControllerDidCancel:(WMPatientTableViewController *)viewController
{
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    [viewController clearAllReferences];
    _navigationNodePopoverController = nil;
}

#pragma mark - PatientDetailViewControllerDelegate

- (void)patientDetailViewControllerDidUpdatePatient:(WMPatientDetailViewController *)viewController
{
    [super patientDetailViewControllerDidUpdatePatient:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
}

- (void)patientDetailViewControllerDidCancelUpdate:(WMPatientDetailViewController *)viewController
{
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    [viewController clearAllReferences];
    _navigationNodePopoverController = nil;
    // confirm that we have a clean moc
    NSAssert1(![self.managedObjectContext hasChanges], @"self.managedObjectContext has changes", self.managedObjectContext);
}

#pragma mark - SelectWoundViewControllerDelegate

- (void)selectWoundController:(WMSelectWoundViewController *)viewController didSelectWound:(WMWound *)wound
{
    [super selectWoundController:viewController didSelectWound:wound];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)selectWoundControllerDidCancel:(WMSelectWoundViewController *)viewController
{
    [super selectWoundControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - WoundDetailViewControllerDelegate

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didUpdateWound:(WMWound *)wound
{
    [super woundDetailViewController:viewController didUpdateWound:wound];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)woundDetailViewControllerDidCancelUpdate:(WMWoundDetailViewController *)viewController
{
    [super woundDetailViewControllerDidCancelUpdate:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didDeleteWound:(WMWound *)wound
{
    [super woundDetailViewController:viewController didDeleteWound:wound];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - BradenScaleDelegate

- (void)bradenScaleControllerDidFinish:(WMBradenScaleViewController *)viewController
{
    [super bradenScaleControllerDidFinish:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - MedicationGroupViewControllerDelegate

- (void)medicationGroupViewControllerDidSave:(WMMedicationGroupViewController *)viewController
{
    [super medicationGroupViewControllerDidSave:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)medicationGroupViewControllerDidCancel:(WMMedicationGroupViewController *)viewController
{
    [super medicationGroupViewControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - DevicesViewControllerDelegate

- (void)devicesViewControllerDidSave:(WMDevicesViewController *)viewController
{
    [super devicesViewControllerDidSave:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)devicesViewControllerDidCancel:(WMDevicesViewController *)viewController
{
    [super devicesViewControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - PsychoSocialGroupViewControllerDelegate

- (void)psychoSocialGroupViewControllerDidFinish:(WMPsychoSocialGroupViewController *)viewController
{
    [super psychoSocialGroupViewControllerDidFinish:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)psychoSocialGroupViewControllerDidCancel:(WMPsychoSocialGroupViewController *)viewController
{
    [super psychoSocialGroupViewControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - NutritionGroupViewControllerDelegate

- (void)nutritionGroupViewControllerDidSave:(WMNutritionGroupViewController *)viewController
{
    [super nutritionGroupViewControllerDidSave:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)nutritionGroupViewControllerDidCancel:(WMNutritionGroupViewController *)viewController
{
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - SkinAssessmentGroupViewControllerDelegate

- (void)skinAssessmentGroupViewControllerDidSave:(WMSkinAssessmentGroupViewController *)viewController
{
    [super skinAssessmentGroupViewControllerDidSave:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)skinAssessmentGroupViewControllerDidCancel:(WMSkinAssessmentGroupViewController *)viewController
{
    [super skinAssessmentGroupViewControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - TakePatientPhotoDelegate

- (void)takePatientPhotoViewControllerDidFinish:(WMTakePatientPhotoViewController *)viewController
{
    [super takePatientPhotoViewControllerDidFinish:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
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
            if (!photoManager.shouldUseCameraForNextPhoto) {
                [_navigationNodePopoverController dismissPopoverAnimated:YES];
                _navigationNodePopoverController = nil;
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    // nothing more
                }];
            }
            self.photoAcquisitionState = PhotoAcquisitionStateNone;
            break;
        }
        case PhotoAcquisitionStateAcquirePatientPhoto: {
            // process image in background using self.photoManager scaleAndCenterPatientPhoto:(UIImage *)photo rect:(CGRect)rect
            [self dismissViewControllerAnimated:YES completion:^{
                self.photoAcquisitionState = PhotoAcquisitionStateNone;
            }];
            break;
        }
    }
}

- (void)photoManagerDidCancelCaptureImage:(WMPhotoManager *)photoManager
{
    if (!photoManager.shouldUseCameraForNextPhoto) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

#pragma mark - WoundTreatmentGroupsDelegate

- (void)woundTreatmentGroupsViewControllerDidFinish:(WMWoundTreatmentGroupsViewController *)viewController
{
    [super woundTreatmentGroupsViewControllerDidFinish:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)woundTreatmentGroupsViewControllerDidCancel:(WMWoundTreatmentGroupsViewController *)viewController
{
    [super woundTreatmentGroupsViewControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - WoundMeasurementGroupViewControllerDelegate

- (void)woundMeasurementGroupViewControllerDidFinish:(WMWoundMeasurementGroupViewController *)viewController
{
    [super woundMeasurementGroupViewControllerDidFinish:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)woundMeasurementGroupViewControllerDidCancel:(WMWoundMeasurementGroupViewController *)viewController
{
    [super woundMeasurementGroupViewControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - PlotViewControllerDelegate

- (void)plotViewControllerDidCancel:(WMBaseViewController *)viewController
{
    [super plotViewControllerDidCancel:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

- (void)plotViewControllerDidFinish:(WMBaseViewController *)viewController
{
    [super plotViewControllerDidFinish:viewController];
    // could be PlotSelectDatasetViewController, PlotConfigureGraphViewController, or PlotGraphViewController
    if ([viewController isKindOfClass:[WMPlotSelectDatasetViewController class]] || [viewController isKindOfClass:[WMPlotConfigureGraphViewController class]]) {
        [_navigationNodePopoverController dismissPopoverAnimated:YES];
        _navigationNodePopoverController = nil;
    } else if ([viewController isKindOfClass:[WMPlotGraphViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:^{
            // nothing
        }];
    }
}

#pragma mark - PatientSummaryContainerDelegate

- (void)patientSummaryContainerViewControllerDidFinish:(WMPatientSummaryContainerViewController *)viewController
{
    [super patientSummaryContainerViewControllerDidFinish:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

#pragma mark - ShareViewControllerDelegate

- (void)shareViewControllerDidFinish:(WMShareViewController *)viewController
{
    [super shareViewControllerDidFinish:viewController];
    [_navigationNodePopoverController dismissPopoverAnimated:YES];
    _navigationNodePopoverController = nil;
}

@end

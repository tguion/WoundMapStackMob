//
//  WMHomeBaseViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMNavigationPatientWoundContainerView.h"
#import "WMWoundTreatmentGroupsViewController.h"
#import "WMPolicyEditorViewController.h"
#import "WMPatientTableViewController.h"
#import "WMSelectWoundViewController.h"
#import "WMWoundDetailViewController.h"
#import "WMChooseTrackViewController.h"
#import "WMChooseStageViewController.h"
#import "WMPatientDetailViewController.h"
#import "WMSkinAssessmentGroupViewController.h"
#import "WMBradenScaleViewController.h"
#import "WMMedicationGroupViewController.h"
#import "WMDevicesViewController.h"
#import "WMPsychoSocialGroupViewController.h"
#import "WMNutritionGroupViewController.h"
#import "WMTakePatientPhotoViewController.h"
#import "WMWoundMeasurementGroupViewController.h"
#import "WMPhotosContainerViewController.h"
#import "WMCarePlanGroupViewController.h"
#import "WMPatientSummaryContainerViewController.h"
#import "WMInstructionsViewController.h"
#import "WMPlotSelectDatasetViewController.h"
#import "WMShareViewController.h"
#import "WMManageTeamViewController.h"
#import "WMWelcomeToWoundMapViewController.h"
#import "WMCompassView.h"
#import "TakePhotoProtocols.h"

// maitain state for type of photo taken
typedef enum {
    PhotoAcquisitionStateNone,
    PhotoAcquisitionStateAcquirePatientPhoto,
    PhotoAcquisitionStateAcquireWoundPhoto,
} PhotoAcquisitionState;

@class WMNavigationNode;
@class WMPatientTableViewController, WMPatientDetailViewController, WMSelectWoundViewController, WMWoundDetailViewController;
@class WMSkinAssessmentGroupViewController, WMBradenScaleViewController, WMMedicationGroupViewController, WMDevicesViewController, WMPsychoSocialGroupViewController, WMNutritionGroupViewController;
@class WMCarePlanGroupViewController, WMWoundTreatmentGroupsViewController, WMWoundMeasurementGroupViewController, WMTakePatientPhotoViewController;
@class WMPhotosContainerViewController, WMPlotSelectDatasetViewController, WMPatientSummaryContainerViewController, WMShareViewController;

@interface WMHomeBaseViewController : WMBaseViewController
<PolicyEditorDelegate, PatientTableViewControllerDelegate, SelectWoundViewControllerDelegate, WoundDetailViewControllerDelegate, NavigationPatientWoundViewDelegate, ChooseTrackDelegate, ChooseStageDelegate, WoundTreatmentGroupsDelegate, UIPopoverControllerDelegate, PlotViewControllerDelegate, ShareViewControllerDelegate, PatientDetailViewControllerDelegate, BradenScaleDelegate, MedicationGroupViewControllerDelegate, DevicesViewControllerDelegate, SkinAssessmentGroupViewControllerDelegate, CarePlanGroupViewControllerDelegate, WoundMeasurementGroupViewControllerDelegate, TakePatientPhotoDelegate, PatientSummaryContainerDelegate, PsychoSocialGroupViewControllerDelegate, OverlayViewControllerDelegate, NutritionGroupViewControllerDelegate>

@property (nonatomic) PhotoAcquisitionState photoAcquisitionState;

@property (strong, nonatomic) IBOutlet WMNavigationPatientWoundContainerView *navigationPatientWoundContainerView;
@property (strong, nonatomic) IBOutlet UITableViewCell *trackTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *stageTableViewCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *stageSegmentedControl;
@property (strong, nonatomic) IBOutlet UITableViewCell *compassCell;
@property (strong, nonatomic) IBOutlet WMCompassView *compassView;
@property (strong, nonatomic) UITableViewCell *carePlanCell;

@property (nonatomic) BOOL patientWoundUIRequiresUpdate;                // YES if need to reload the patient/wound UI
@property (nonatomic) BOOL navigationUIRequiresUpdate;                  // YES if need to reload the navigation UI
@property (readonly, nonatomic) BOOL shouldShowSelectTrackTableViewCell;// most clinical setting will allow changing clinical setting
@property (readonly, nonatomic) BOOL shouldShowSelectStageTableViewCell;// most cliical settings will allow selecting stage of care
@property (nonatomic) BOOL removeTrackAndStageForSubnodes;              // defaults to NO - continue to show when subnodes are displayed

@property (weak, nonatomic) IBOutlet UILabel *breadcrumbLabel;
@property (readonly, nonatomic) NSString *breadcrumbString;

@property (strong, nonatomic) WMNavigationNode *parentNavigationNode;   // parent node to displayed task nodes, may be nil if root node
@property (strong, nonatomic) NSArray *navigationNodes;                 // current task set (WCNavigationNode), displayed on compass view
@property (strong, nonatomic) NSArray *navigationNodeControls;          // controls for navigationNodes

@property (readonly, nonatomic) WMNavigationNode *initialStageNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *followupStageNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *dischargeStageNavigationNode;

@property (readonly, nonatomic) WMNavigationNodeButton *selectPatientButton;
@property (readonly, nonatomic) WMNavigationNodeButton *editPatientButton;
@property (readonly, nonatomic) WMNavigationNodeButton *addPatientButton;
@property (readonly, nonatomic) WMNavigationNodeButton *selectWoundButton;
@property (readonly, nonatomic) WMNavigationNodeButton *editWoundButton;
@property (readonly, nonatomic) WMNavigationNodeButton *addWoundButton;

@property (readonly, nonatomic) WMNavigationNode *addPatientNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *selectPatientNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *editPatientNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *addWoundNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *selectWoundNavigationNode;
@property (readonly, nonatomic) WMNavigationNode *editWoundNavigationNode;

@property (readonly, nonatomic) MapBaseRotationDirection rotationState; // W, N, E, S current compass needle rotation position

@property (weak, nonatomic) IBOutlet UIButton *shareButton;             // button to show email, print, etc.
@property (readonly, nonatomic) UIImage *openReferralStatusImage;

@property (weak, nonatomic) UIBarButtonItem *reviewPhotosBarButtonItem;
@property (weak, nonatomic) UIBarButtonItem *reviewGraphsBarButtonItem;
@property (weak, nonatomic) UIBarButtonItem *patientSummaryBarButtonItem;

@property (readonly, nonatomic) WMManageTeamViewController *manageTeamViewController;
@property (readonly, nonatomic) UIViewController *welcomeToWoundMapViewController;

@property (readonly, nonatomic) WMPatientTableViewController *patientTableViewController;
@property (readonly, nonatomic) WMPatientDetailViewController *patientDetailViewController;
@property (readonly, nonatomic) WMSelectWoundViewController *selectWoundViewController;
@property (readonly, nonatomic) WMWoundDetailViewController *woundDetailViewController;

@property (readonly, nonatomic) WMSkinAssessmentGroupViewController *skinAssessmentGroupViewController;
@property (readonly, nonatomic) WMBradenScaleViewController *bradenScaleViewController;
@property (readonly, nonatomic) WMMedicationGroupViewController *medicationsViewController;
@property (readonly, nonatomic) WMDevicesViewController *devicesViewController;
@property (readonly, nonatomic) WMPsychoSocialGroupViewController *psychoSocialGroupViewController;
@property (readonly, nonatomic) WMNutritionGroupViewController *nutritionGroupViewController;
@property (readonly, nonatomic) WMCarePlanGroupViewController *carePlanGroupViewController;
@property (readonly, nonatomic) WMWoundTreatmentGroupsViewController *woundTreatmentGroupsViewController;
@property (readonly, nonatomic) WMWoundMeasurementGroupViewController *woundMeasurementGroupViewController;
@property (readonly, nonatomic) WMTakePatientPhotoViewController *takePatientPhotoViewController;

@property (readonly, nonatomic) WMPhotosContainerViewController *photosContainerViewController;
@property (readonly, nonatomic) WMPlotSelectDatasetViewController *plotSelectDatasetViewController;
@property (readonly, nonatomic) WMPatientSummaryContainerViewController *patientSummaryContainerViewController;

@property (readonly, nonatomic) WMShareViewController *shareViewController;

- (void)updateNavigationBar NS_REQUIRES_SUPER;
- (void)rotateCompassToRecommendedTask;
- (void)enableOrDisableNavigationNodes;

- (IBAction)homeAction:(id)sender;
- (IBAction)editPoliciesAction:(id)sender;
- (IBAction)editUserOrTeamAction:(id)sender;
- (IBAction)viewInstructionsAction:(id)sender;

- (IBAction)selectPatientAction:(id)sender;
- (IBAction)editPatientAction:(id)sender;
- (IBAction)addPatientAction:(id)sender;

- (IBAction)selectWoundAction:(id)sender;
- (IBAction)editWoundAction:(id)sender;
- (IBAction)addWoundAction:(id)sender;

- (IBAction)takePatientPhotoAction:(id)sender;

- (IBAction)riskAssessmentAction:(id)sender;

- (void)navigateToNavigationTracks;

- (void)navigateToPatientDetail:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToPatientDetailViewControllerForNewPatient:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToSelectPatient:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToWoundDetail:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToWoundDetailViewControllerForNewWound:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToSelectWound:(WMNavigationNodeButton *)navigationNodeButton;

- (void)navigateToManageTeam:(UIBarButtonItem *)barButtonItem;

- (void)navigateToSkinAssessmentForNavigationNode:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToBradenScaleAssessment:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToMedicationAssessment:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToDeviceAssessment:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToPsychoSocialAssessment:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToNutritionAssessment:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToPhoto:(WMNavigationNode *)navigationNode;
- (void)navigateToTakePhoto:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToMeasurePhoto:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToWoundAssessment:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToWoundTreatment:(WMNavigationNodeButton *)navigationNodeButton;
- (void)navigateToCarePlan;
- (void)navigateToBrowsePhotos:(id)sender;
- (void)navigateToViewGraphs:(id)sender;
- (void)navigateToPatientSummary:(id)sender;
- (void)navigateToShare:(id)sender;


@end

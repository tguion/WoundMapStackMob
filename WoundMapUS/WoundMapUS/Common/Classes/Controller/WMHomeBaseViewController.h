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
#import "WMPlotSelectDatasetViewController.h"
#import "WMShareViewController.h"
#import "WMCompassView.h"

@class WMNavigationNode;
@class WMPatientTableViewController, WMPatientDetailViewController, WMSelectWoundViewController, WMWoundDetailViewController;
@class WMSkinAssessmentGroupViewController, WMBradenScaleViewController, WMMedicationGroupViewController, WMDevicesViewController, WMPsychoSocialGroupViewController;
@class WMCarePlanGroupViewController, WMWoundTreatmentGroupsViewController, WMWoundMeasurementGroupViewController, WMTakePatientPhotoViewController;
@class WMPhotosContainerViewController, WMPlotSelectDatasetViewController, WMPatientSummaryContainerViewController, WMShareViewController;

@interface WMHomeBaseViewController : WMBaseViewController

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

@property (weak, nonatomic) UIBarButtonItem *reviewPhotosBarButtonItem;
@property (weak, nonatomic) UIBarButtonItem *reviewGraphsBarButtonItem;
@property (weak, nonatomic) UIBarButtonItem *patientSummaryBarButtonItem;

@property (readonly, nonatomic) WMPatientTableViewController *patientTableViewController;
@property (readonly, nonatomic) WMPatientDetailViewController *patientDetailViewController;
@property (readonly, nonatomic) WMSelectWoundViewController *selectWoundViewController;
@property (readonly, nonatomic) WMWoundDetailViewController *woundDetailViewController;

@property (readonly, nonatomic) WMSkinAssessmentGroupViewController *skinAssessmentGroupViewController;
@property (readonly, nonatomic) WMBradenScaleViewController *bradenScaleViewController;
@property (readonly, nonatomic) WMMedicationGroupViewController *medicationsViewController;
@property (readonly, nonatomic) WMDevicesViewController *devicesViewController;
@property (readonly, nonatomic) WMPsychoSocialGroupViewController *psychoSocialGroupViewController;
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

@end

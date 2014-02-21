//
//  WMHomeBaseViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMPatientTableViewController.h"
#import "WMSelectWoundViewController.h"
#import "WMWoundDetailViewController.h"
#import "WMChooseTrackViewController.h"
#import "WMChooseStageViewController.h"
#import "WMNavigationPatientWoundContainerView.h"
#import "WMWoundTreatmentGroupsViewController.h"
#import "WMPlotSelectDatasetViewController.h"
#import "WMShareViewController.h"
#import "WMCompassView.h"

@class WMNavigationNode;

@interface WMHomeBaseViewController : WMBaseViewController
<PatientTableViewControllerDelegate, SelectWoundViewControllerDelegate, WoundDetailViewControllerDelegate, NavigationPatientWoundViewDelegate, ChooseTrackDelegate, ChooseStageDelegate, WoundTreatmentGroupsDelegate, UIPopoverControllerDelegate, PlotViewControllerDelegate, ShareViewControllerDelegate>

@property (strong, nonatomic) IBOutlet WMNavigationPatientWoundContainerView *navigationPatientWoundContainerView;
@property (strong, nonatomic) IBOutlet UITableViewCell *trackTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *stageTableViewCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *stageSegmentedControl;
@property (strong, nonatomic) IBOutlet UITableViewCell *compassCell;
@property (strong, nonatomic) IBOutlet WMCompassView *compassView;
@property (strong, nonatomic) UITableViewCell *carePlanCell;

@property (nonatomic) BOOL navigationUIRequiresUpdate;                  // YES if need to reload the navigation UI
@property (readonly, nonatomic) BOOL shouldShowSelectTrackTableViewCell;
@property (readonly, nonatomic) BOOL shouldShowSelectStageTableViewCell;
@property (nonatomic) BOOL removeTrackAndStageForSubnodes;              // defaults to NO

@property (strong, nonatomic) WMNavigationNode *parentNavigationNode;   // parent node to navigationNodes, may be nil if root node
@property (strong, nonatomic) NSArray *navigationNodes;                 // current task set (WCNavigationNode), situated on campass directions
@property (strong, nonatomic) NSArray *navigationNodeControls;          // controls for navigationNodes

@property (readonly, nonatomic) MapBaseRotationDirection rotationState; // W, N, E, S current compass needle rotation position

@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end

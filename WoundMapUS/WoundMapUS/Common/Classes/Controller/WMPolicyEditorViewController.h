//
//  WMPolicyEditorViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMChooseTrackViewController.h"
#import "WMChooseStageViewController.h"

extern NSString * const kEditNodeCellIdentifier;
extern NSString * const kSubnodeCellIdentifier;
extern NSString * const kChooseTrackCellIdentifier;
extern NSString * const kChooseStageCellIdentifier;
extern NSString * const kReorderNodeCellIdentifier;

@class WMPolicyEditorViewController, WMNavigationNode;

@protocol PolicyEditorDelegate <NSObject>

- (void)policyEditorViewControllerDidSave:(WMPolicyEditorViewController *)viewController;
- (void)policyEditorViewController:(WMPolicyEditorViewController *)viewController didChangeTrack:(WMNavigationTrack *)navigationTrack;
- (void)policyEditorViewControllerDidCancel:(WMPolicyEditorViewController *)viewController;

@end

@interface WMPolicyEditorViewController : WMBaseViewController <PolicyEditorDelegate>

@property (weak, nonatomic) id<PolicyEditorDelegate> delegate;
@property (strong, nonatomic) WMNavigationNode *parentNavigationNode;

@property (nonatomic) BOOL updateCurrentPatientFlag;

- (void)reorderNodesFromSortOrderings;
- (void)configureNavigationNodeCell:(UITableViewCell *)cell forNavigationNode:(WMNavigationNode *)navigationNode;

@end

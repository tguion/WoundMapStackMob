//
//  WMPolicyEditorViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMPolicyEditorViewController, WMNavigationNode;

@protocol PolicyEditorDelegate <NSObject>

- (void)policyEditorViewControllerDidSave:(WMPolicyEditorViewController *)viewController;
- (void)policyEditorViewControllerDidChangeTrack:(WMPolicyEditorViewController *)viewController;
- (void)policyEditorViewControllerDidCancel:(WMPolicyEditorViewController *)viewController;

@end

@interface WMPolicyEditorViewController : WMBaseViewController

@property (weak, nonatomic) id<PolicyEditorDelegate> delegate;
@property (strong, nonatomic) WMNavigationNode *parentNavigationNode;

@property (nonatomic) BOOL updateCurrentPatientFlag;

- (void)reorderNodesFromSortOrderings;
- (void)configureNavigationNodeCell:(UITableViewCell *)cell forNavigationNode:(WMNavigationNode *)navigationNode;

@end

//
//  WMSkinAssessmentGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMSkinAssessmentGroupViewController;
@class WMSkinAssessmentGroup, WMNavigationNode;

@protocol SkinAssessmentGroupViewControllerDelegate <NSObject>

- (void)skinAssessmentGroupViewControllerDidSave:(WMSkinAssessmentGroupViewController *)viewController;
- (void)skinAssessmentGroupViewControllerDidCancel:(WMSkinAssessmentGroupViewController *)viewController;

@end

@interface WMSkinAssessmentGroupViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<SkinAssessmentGroupViewControllerDelegate> delegate;
@property (strong, nonatomic) WMNavigationNode *navigationNode;

@end

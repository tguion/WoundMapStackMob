//
//  WMInterventionStatusViewController.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"

@class WMInterventionStatusViewController;
@class WMInterventionStatus;

@protocol InterventionStatusViewControllerDelegate <NSObject>

@property (readonly, nonatomic) WMInterventionStatus *selectedInterventionStatus;
@property (readonly, nonatomic) id<AssessmentGroup>assessmentGroup;
@property (readonly, nonatomic) NSString *summaryButtonTitle;
@property (readonly, nonatomic) UIViewController *summaryViewController;

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus;
- (void)interventionStatusViewControllerDidCancel:(WMInterventionStatusViewController *)viewController;

@end

@interface WMInterventionStatusViewController : WMBaseViewController

@property (weak, nonatomic) id<InterventionStatusViewControllerDelegate> delegate;
@property (strong, nonatomic) WMInterventionStatus *selectedInterventionStatus;

@end

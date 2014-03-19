//
//  WMInterventionEventViewController.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"

@class WMInterventionEventViewController;

@protocol InterventionEventViewControllerDelegate <NSObject>

@property (readonly, nonatomic) id<AssessmentGroup> assessmentGroup;

- (void)interventionEventViewControllerDidCancel:(WMInterventionEventViewController *)viewController;

@end

@interface WMInterventionEventViewController : WMBaseViewController

@property (weak, nonatomic) id<InterventionEventViewControllerDelegate> delegate;
@property (strong, nonatomic) id<AssessmentGroup> assessmentGroup;

@end

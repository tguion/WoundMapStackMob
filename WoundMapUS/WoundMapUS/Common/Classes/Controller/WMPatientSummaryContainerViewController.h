//
//  WMPatientSummaryContainerViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

@class WMPatientSummaryContainerViewController;

@protocol PatientSummaryContainerDelegate <NSObject>

- (void)patientSummaryContainerViewControllerDidFinish:(WMPatientSummaryContainerViewController *)viewController;

@end

@interface WMPatientSummaryContainerViewController : UIViewController

@property (weak, nonatomic) id<PatientSummaryContainerDelegate> delegate;

@end

//
//  WMPatientReferralViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/2/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMPatientReferralViewController;
@class WMPatientReferral;

@protocol PatientReferralDelegate <NSObject>

- (void)patientReferralViewControllerDidFinish:(WMPatientReferralViewController *)viewController;
- (void)patientReferralViewControllerDidCancel:(WMPatientReferralViewController *)viewController;

@end

@interface WMPatientReferralViewController : WMBaseViewController

@property (weak, nonatomic) id<PatientReferralDelegate> delegate;
@property (strong, nonatomic) WMPatientReferral *patientReferral;

@end

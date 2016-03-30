//
//  WMPatientTableViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/16/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMPatientTableViewController, WMPatient;

@protocol PatientTableViewControllerDelegate <NSObject>

- (void)patientTableViewController:(WMPatientTableViewController *)viewController didSelectPatient:(WMPatient *)patient;
- (void)patientTableViewControllerDidCancel:(WMPatientTableViewController *)viewController;

@end

@interface WMPatientTableViewController : WMBaseViewController

@property (weak, nonatomic) id<PatientTableViewControllerDelegate> delegate;

@end

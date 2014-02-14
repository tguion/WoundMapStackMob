//
//  WMPatientDetailViewController.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/29/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMBaseViewController.h"
//#import "WoundDetailViewController.h"

@class WCPatient;
@class WMPatientDetailViewController;

@protocol PatientDetailViewControllerDelegate <NSObject>

- (void)patientDetailViewControllerDidUpdatePatient:(WMPatientDetailViewController *)viewController;
- (void)patientDetailViewControllerDidCancelUpdate:(WMPatientDetailViewController *)viewController;

@end

@interface WMPatientDetailViewController : WMBaseViewController <UITextFieldDelegate, UIAlertViewDelegate/*, WoundDetailViewControllerDelegate*/>

@property (weak, nonatomic) id<PatientDetailViewControllerDelegate>delegate;

@property (nonatomic, getter = isNewPatient) BOOL newPatientFlag;
@property (nonatomic) BOOL hideAddWoundFlag;

@end

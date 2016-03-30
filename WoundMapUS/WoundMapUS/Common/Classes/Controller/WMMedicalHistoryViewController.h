//
//  WMMedicalHistoryViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 4/8/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMMedicalHistoryViewController;

@protocol MedicalHistoryViewControllerDelegate <NSObject>

@property (readonly, nonatomic) WMPatient *patient;

- (void)medicalHistoryViewControllerDidFinish:(WMMedicalHistoryViewController *)viewController;
- (void)medicalHistoryViewControllerDidCancel:(WMMedicalHistoryViewController *)viewCnotroller;

@end

@interface WMMedicalHistoryViewController : WMBaseViewController

@property (weak, nonatomic) id<MedicalHistoryViewControllerDelegate> delegate;

@end

//
//  WMWoundTreatmentSummaryViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

@class WMWound, WMWoundTreatmentGroup;

@interface WMWoundTreatmentSummaryViewController : UIViewController

@property (strong, nonatomic) WMWoundTreatmentGroup *woundTreatmentGroup;
@property (strong, nonatomic) WMWound *selectedWound;

@end

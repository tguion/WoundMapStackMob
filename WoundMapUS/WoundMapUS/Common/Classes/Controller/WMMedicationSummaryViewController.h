//
//  WMMedicationSummaryViewController.h
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

@class WMMedicationGroup;

@interface WMMedicationSummaryViewController : UIViewController

@property (strong, nonatomic) WMMedicationGroup *medicationGroup;
@property (nonatomic) BOOL drawFullHistory;

@end

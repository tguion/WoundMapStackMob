//
//  WMCarePlanSummaryViewController.h
//  WoundPUMP
//
//  Created by Todd Guion on 5/4/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

@class WMCarePlanGroup, WMCarePlanSummaryViewController;

@interface WMCarePlanSummaryViewController : UIViewController

@property (strong, nonatomic) WMCarePlanGroup *carePlanGroup;
@property (nonatomic) BOOL drawFullHistory;

@end

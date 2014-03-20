//
//  WMSkinAssessmentSummaryViewController.h
//  WoundPUMP
//
//  Created by Todd Guion on 5/5/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

@class WMSkinAssessmentGroup;

@interface WMSkinAssessmentSummaryViewController : UIViewController

@property (strong, nonatomic) WMSkinAssessmentGroup *skinAssessmentGroup;
@property (nonatomic) BOOL drawFullHistory;

@end

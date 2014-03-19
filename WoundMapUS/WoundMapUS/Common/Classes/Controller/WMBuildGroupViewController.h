//
//  WMBuildGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"
#import "WMInterventionStatusViewController.h"
#import "WMInterventionEventViewController.h"
#import "WMAssessmentTableViewCell.h"

@interface WMBuildGroupViewController : WMBaseViewController <InterventionStatusViewControllerDelegate, InterventionEventViewControllerDelegate, AssessmentTableViewCellDelegate, UITextFieldDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) NSInteger recentlyClosedCount;

@end

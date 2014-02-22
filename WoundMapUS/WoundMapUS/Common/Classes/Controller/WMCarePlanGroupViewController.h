//
//  WMCarePlanGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMCarePlanGroupViewController;
@class WMCarePlanGroup;

@protocol CarePlanGroupViewControllerDelegate <NSObject>

- (void)carePlanGroupViewControllerDidSave:(WMCarePlanGroupViewController *)viewController;
- (void)carePlanGroupViewControllerDidCancel:(WMCarePlanGroupViewController *)viewController;

@end

@interface WMCarePlanGroupViewController : WMBuildGroupViewController

@end

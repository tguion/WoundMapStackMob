//
//  WMMedicationGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMMedicationGroupViewController;
@class WMMedicationGroup;

@protocol MedicationGroupViewControllerDelegate <NSObject>

- (void)medicationGroupViewControllerDidSave:(WMMedicationGroupViewController *)viewController;
- (void)medicationGroupViewControllerDidCancel:(WMMedicationGroupViewController *)viewController;

@end

@interface WMMedicationGroupViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<MedicationGroupViewControllerDelegate> delegate;
@property (strong, nonatomic) WMMedicationGroup *medicationGroup;

@end

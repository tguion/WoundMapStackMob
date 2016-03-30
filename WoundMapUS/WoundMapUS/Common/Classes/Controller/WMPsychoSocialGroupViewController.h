//
//  WMPsychoSocialGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMPsychoSocialGroup, WMPsychoSocialGroupViewController;

@protocol PsychoSocialGroupViewControllerDelegate <NSObject>

- (void)psychoSocialGroupViewControllerDidFinish:(WMPsychoSocialGroupViewController *)viewController;
- (void)psychoSocialGroupViewControllerDidCancel:(WMPsychoSocialGroupViewController *)viewController;

@end

@interface WMPsychoSocialGroupViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<PsychoSocialGroupViewControllerDelegate> delegate;

@end

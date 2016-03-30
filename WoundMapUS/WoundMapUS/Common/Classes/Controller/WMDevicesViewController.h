//
//  WMDevicesViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMDevicesViewController;
@class WMDeviceGroup;

@protocol DevicesViewControllerDelegate <NSObject>

- (void)devicesViewControllerDidSave:(WMDevicesViewController *)viewController;
- (void)devicesViewControllerDidCancel:(WMDevicesViewController *)viewController;

@end

@interface WMDevicesViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<DevicesViewControllerDelegate> delegate;

@end

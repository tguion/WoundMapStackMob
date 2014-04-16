//
//  WMSelectWoundPositionViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/14/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMSelectWoundPositionViewController;
@class WMWoundLocation, WMWoundPosition;

@protocol SelectWoundPositionViewControllerDelegate <NSObject>

- (void)selectWoundPositionViewControllerDidSave:(WMSelectWoundPositionViewController *)viewController;
- (void)selectWoundPositionViewControllerDidCancel:(WMSelectWoundPositionViewController *)viewController;

@end

@interface WMSelectWoundPositionViewController : WMBuildGroupViewController 

@property (weak, nonatomic) id<SelectWoundPositionViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWound *wound;
@property (strong, nonatomic) WMWoundLocation *woundLocation;

@end

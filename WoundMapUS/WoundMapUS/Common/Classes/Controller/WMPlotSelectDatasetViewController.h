//
//  WMPlotSelectDatasetViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMSimpleTableViewController.h"

@class WMPlotSelectDatasetViewController;

@protocol PlotViewControllerDelegate <SimpleTableViewControllerDelegate>

- (void)plotViewControllerDidCancel:(UIViewController *)viewController;
- (void)plotViewControllerDidFinish:(UIViewController *)viewController;

@end

@interface WMPlotSelectDatasetViewController : WMSimpleTableViewController

@property (weak, nonatomic) id<PlotViewControllerDelegate> delegate;

@end

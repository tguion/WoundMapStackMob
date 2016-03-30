//
//  WMFTPConfigurationViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/15/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMFTPConfigurationViewController;

@protocol FTPConfigurationDelegate <NSObject>
- (void)ftpConfigurationViewControllerDidFinish:(WMFTPConfigurationViewController *)viewController;
@end

@interface WMFTPConfigurationViewController : WMBaseViewController

@property (weak, nonatomic) id<FTPConfigurationDelegate> delegate;
@property (strong, nonatomic) NSURL *url;

@end

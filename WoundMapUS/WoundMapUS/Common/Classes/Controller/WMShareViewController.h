//
//  WMShareViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMShareViewController;

@protocol ShareViewControllerDelegate <NSObject>

- (void)shareViewControllerDidFinish:(WMShareViewController *)viewController;

@end

@interface WMShareViewController : WMBaseViewController

@property (weak, nonatomic) id<ShareViewControllerDelegate> delegate;

@end

//
//  WMBarScanViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/17/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMBarScanViewController;

@protocol BarScanViewControllerDelegate <NSObject>

- (void)barScanViewController:(WMBarScanViewController *)viewController didCaptureBarScan:(NSString *)barScanValue;
- (void)barScanViewControllerDidCancel:(WMBarScanViewController *)viewController;

@end

@interface WMBarScanViewController : UIViewController

@property (weak, nonatomic) id<BarScanViewControllerDelegate> delegate;

@end

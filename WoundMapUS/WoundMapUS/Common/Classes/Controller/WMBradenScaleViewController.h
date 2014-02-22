//
//  WMBradenScaleViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMBradenScale;
@class WMBradenScaleViewController;

@protocol BradenScaleDelegate <NSObject>

- (void)bradenScaleControllerDidFinish:(WMBradenScaleViewController *)viewController;

@end

@interface WMBradenScaleViewController : WMBaseViewController

@property (weak, nonatomic) id<BradenScaleDelegate> delegate;

@property (strong, nonatomic) WMBradenScale *bradenScale;

@end

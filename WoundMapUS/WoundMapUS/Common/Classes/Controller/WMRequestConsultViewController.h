//
//  WMRequestConsultViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/19/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMRequestConsultViewController;

@protocol RequestConsultDelegate <NSObject>

- (void)requestConsultViewControllerDidFinish:(WMRequestConsultViewController *)viewController;

@end

@interface WMRequestConsultViewController : WMBaseViewController

@property (weak, nonatomic) id<RequestConsultDelegate> delegate;

@end

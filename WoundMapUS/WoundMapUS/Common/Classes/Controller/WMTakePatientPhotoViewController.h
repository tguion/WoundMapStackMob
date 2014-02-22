//
//  WMTakePatientPhotoViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMTakePatientPhotoViewController;

@protocol TakePatientPhotoDelegate <NSObject>

- (void)takePatientPhotoViewControllerDidFinish:(WMTakePatientPhotoViewController *)viewController;

@end

@interface WMTakePatientPhotoViewController : WMBaseViewController

@property (weak, nonatomic) id<TakePatientPhotoDelegate> delegate;

@end

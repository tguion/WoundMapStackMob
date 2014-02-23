//
//  WMPhotoScaleViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMWoundPhoto;
@class WMPhotoScaleViewController;

@protocol PhotoScaleViewControllerDelegate <NSObject>

- (void)photoScaleViewController:(WMPhotoScaleViewController *)viewController didSetPointsPerCentimeter:(CGFloat)pointsPerCentimeter;
- (void)photoScaleViewControllerDidCancel:(WMPhotoScaleViewController *)viewController;

@end

@interface WMPhotoScaleViewController : WMBaseViewController

@property (weak, nonatomic) id<PhotoScaleViewControllerDelegate> delegate;

@property (nonatomic) CGFloat pointsPerCentimeter;

@end

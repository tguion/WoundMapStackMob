//
//  WMPhotoScaleViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

@class WMWoundPhoto;
@class WMPhotoScaleViewController;

@protocol PhotoScaleViewControllerDelegate <NSObject>

- (void)photoScaleViewController:(WMPhotoScaleViewController *)viewController didSetPointsPerCentimeter:(CGFloat)pointsPerCentimeter;
- (void)photoScaleViewControllerDidCancel:(WMPhotoScaleViewController *)viewController;

@end

@interface WMPhotoScaleViewController : UIViewController

@property (weak, nonatomic) id<PhotoScaleViewControllerDelegate> delegate;

@property (nonatomic) CGFloat pointsPerCentimeter;

@end

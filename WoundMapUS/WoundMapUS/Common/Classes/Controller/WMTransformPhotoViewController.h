//
//  WMTransformPhotoViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

@class WMWoundPhoto;
@class WMTransformPhotoViewController;

@protocol TransformPhotoViewControllerDelegate <NSObject>

- (void)tranformPhotoViewController:(WMTransformPhotoViewController *)viewController didTransformPhoto:(WMWoundPhoto *)woundPhoto;
- (void)tranformPhotoViewControllerDidCancel:(WMTransformPhotoViewController *)viewController;

@end

@interface WMTransformPhotoViewController : UIViewController

@property (weak, nonatomic) id<TransformPhotoViewControllerDelegate> delegate;

@end

//
//  WMWoundPhotoSlideShowViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 8/3/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

@class WMGridImageViewContainer, WMWoundPhotoSlideShowViewController;

@protocol WoundPhotoSlideShowViewControllerDelegate <NSObject>

- (void)woundPhotoSlideShowViewControllerDidFinish:(WMWoundPhotoSlideShowViewController *)viewController;

@end

@interface WMWoundPhotoSlideShowViewController : UIViewController

@property (weak, nonatomic) id<WoundPhotoSlideShowViewControllerDelegate> delegate;

@end

//
//  WMPhotoDepthViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

@class WMPhotoDepthViewController;

@protocol PhotoDepthViewControllerDelegate <NSObject>

- (void)photoDepthViewControllerDelegate:(WMPhotoDepthViewController *)viewController depth:(NSDecimalNumber *)depth;

@end

@interface WMPhotoDepthViewController : UIViewController

@property (weak, nonatomic) id<PhotoDepthViewControllerDelegate> delegate;
@property (nonatomic) BOOL showCancelButton;
@property (nonatomic) CGFloat depth;

@end

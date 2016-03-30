//
//  WMPhotoMeasureViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

@class WMPhotoMeasureViewController;

@protocol PhotoMeasureViewControllerDelegate <NSObject>

- (void)photoMeasureViewControllerDelegate:(WMPhotoMeasureViewController *)viewController length:(NSDecimalNumber *)length width:(NSDecimalNumber *)width;

@end

@interface WMPhotoMeasureViewController : UIViewController

@property (weak, nonatomic) id<PhotoMeasureViewControllerDelegate> delegate;

@property (nonatomic) CGFloat pointsPerCentimeter;

@end

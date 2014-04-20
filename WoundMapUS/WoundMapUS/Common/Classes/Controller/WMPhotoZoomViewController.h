//
//  WMPhotoZoomViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/12/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMImageScrollView, WMWoundMeasurementLabel;

@interface WMPhotoZoomViewController : UIViewController

@property (nonatomic) CGRect initialFrame;                          // initial frame to animate from

@property (weak, nonatomic) IBOutlet WMImageScrollView *scrollView;   // view subclass handle zoom and tiling
@property (weak, nonatomic) IBOutlet WMWoundMeasurementLabel *woundMeasurementLabel;

- (CGRect)targetFrameInView:(UIView *)aView;                        // final frame to animate to

@end

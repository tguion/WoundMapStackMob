//
//  WMUndermineTunnelViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMAdjustAlpaView.h"

@class WMUndermineTunnelViewController, WMWoundMeasurementGroup;

@protocol UndermineTunnelViewControllerDelegate <NSObject>

- (void)undermineTunnelViewControllerDidDone:(WMUndermineTunnelViewController *)viewController;
- (void)undermineTunnelViewControllerDidCancel:(WMUndermineTunnelViewController *)viewController;

@end

@interface WMUndermineTunnelViewController : WMBaseViewController <AdjustAlpaViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) id<UndermineTunnelViewControllerDelegate> delegate;
@property (strong, nonatomic) WMWoundMeasurementGroup *woundMeasurementGroup;

@property (nonatomic) BOOL showCancelButton;

@end

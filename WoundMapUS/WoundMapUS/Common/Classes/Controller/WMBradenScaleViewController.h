//
//  WMBradenScaleViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMBradenScale;
@class WMBradenScaleViewController, WMBradenScaleInputViewController;

@protocol BradenScaleDelegate <NSObject>

- (void)bradenScaleControllerDidFinish:(WMBradenScaleViewController *)viewController;

@end

@protocol BradenScaleInputDelegate <NSObject>

- (void)bradenScaleInputController:(WMBradenScaleInputViewController *)viewController didFinishWithBradenScale:(WMBradenScale *)bradenScale;
- (void)bradenScaleInputControllerDidCancel:(WMBradenScaleInputViewController *)viewController;

@end

@interface WMBradenScaleViewController : WMBaseViewController

@property (weak, nonatomic) id<BradenScaleDelegate> delegate;

@property (strong, nonatomic) WMBradenScale *bradenScale;

@end

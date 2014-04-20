//
//  WMComparePhotosViewController.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/27/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPhotoGridViewController.h"
#import "KalDelegate.h"

@class WCWoundPhoto;

@interface WMComparePhotosViewController : WMPhotoGridViewController <KalDelegateDelegate>

@property (strong, nonatomic) KalDelegate *leftKalDelegate;
@property (strong, nonatomic) KalDelegate *rightKalDelegate;

@end

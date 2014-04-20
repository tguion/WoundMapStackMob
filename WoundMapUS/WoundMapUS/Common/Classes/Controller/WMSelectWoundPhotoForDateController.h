//
//  WMSelectWoundPhotoForDateController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 8/3/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "KalViewController.h"
#import "WMPhotosContainerViewController.h"

@interface WMSelectWoundPhotoForDateController : KalViewController

@property (weak, nonatomic) id<WoundPhotoCache> cacheDelegate;

@end

//
//  WMSelectWoundPhotoViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/25/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSelectWoundPhotoViewController;
@class WMWound;

@protocol SelectWoundPhotoViewControllerDelegate <NSObject>

@property (readonly, nonatomic) WMWound *selectedWound;
@property (readonly, nonatomic) NSArray *selectedWoundPhotos;

- (void)selectWoundPhotoViewController:(WMSelectWoundPhotoViewController *)viewController didSelectWoundPhotos:(NSArray *)woundPhotos;
- (void)selectWoundPhotoViewControllerDidCancel:(WMSelectWoundPhotoViewController *)viewContoller;

@end

@interface WMSelectWoundPhotoViewController : WMBaseViewController

@property (weak, nonatomic) id<SelectWoundPhotoViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableSet *selectedWoundPhotos;

@end

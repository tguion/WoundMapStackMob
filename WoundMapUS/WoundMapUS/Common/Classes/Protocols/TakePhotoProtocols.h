//
//  TakePhotoProtocols.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/8/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#ifndef WoundCarePhoto_TakePhotoProtocols_h
#define WoundCarePhoto_TakePhotoProtocols_h

@class WMWoundPhoto;
@class WMWoundPhotoViewController, WMPhotoManager;

@protocol WoundPhotoViewControllerDelegate <NSObject>
- (void)controller:(WMWoundPhotoViewController *)viewController didSelectWoundPhoto:(WMWoundPhoto *)woundPhoto;
@end

@protocol OverlayViewControllerDelegate <NSObject>
- (void)photoManager:(WMPhotoManager *)photoManager didCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata;
- (void)photoManagerDidCancelCaptureImage:(WMPhotoManager *)photoManager;
@end


#endif

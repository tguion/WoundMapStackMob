//
//  TakePhotoProtocols.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/8/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#ifndef WoundCarePhoto_TakePhotoProtocols_h
#define WoundCarePhoto_TakePhotoProtocols_h

@class WCWoundPhoto;
@class WoundPhotoViewController, PhotoManager;

@protocol WoundPhotoViewControllerDelegate <NSObject>
- (void)controller:(WoundPhotoViewController *)viewController didSelectWoundPhoto:(WCWoundPhoto *)woundPhoto;
@end

@protocol OverlayViewControllerDelegate <NSObject>
- (void)photoManager:(PhotoManager *)photoManager didCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata;
- (void)photoManagerDidCancelCaptureImage:(PhotoManager *)photoManager;
@end


#endif

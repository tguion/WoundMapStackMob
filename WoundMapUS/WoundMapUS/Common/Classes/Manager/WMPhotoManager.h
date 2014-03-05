//
//  WMPhotoManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "TakePhotoProtocols.h"

NSString *const kTaskDidCompleteNotification = @"TaskDidCompleteNotification";

@class WMWound, WMWoundPhoto, WMPhoto;

@interface WMPhotoManager : NSObject

+ (WMPhotoManager *)sharedInstance;

+ (void)applyTransform:(UIView *)aView forWoundPhoto:(WMWoundPhoto *)woundPhoto;

@property (weak, nonatomic) id<OverlayViewControllerDelegate> delegate;             // delegate to handle taking photo process

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) BOOL usePhotoLibraryForNextPhoto;
@property (readonly, nonatomic) BOOL shouldUseCameraForNextPhoto;

- (void)setupImagePicker;

- (void)loadImageFromAssetURL:(NSURL *)assetURL into:(UIImage **)image;

- (WMWoundPhoto *)processNewImage:(UIImage *)image
                         metadata:(NSDictionary *)metadata
                            wound:(WMWound *)wound
                         document:(UIManagedDocument *)document;

// patient photo

- (UIImage *)scaleAndCenterPatientPhoto:(UIImage *)photo rect:(CGRect)rect success:(BOOL *)success;

@end

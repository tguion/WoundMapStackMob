//
//  WMPhotoManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "TakePhotoProtocols.h"

#define kMaximumThumbnailMiniWidth 40.0
#define kMaximumThumbnailWidth 320.0
#define kMaximumThumbnailHeight 460.0
#define kMaximumPadThumbnailWidth 768.0
#define kMaximumPadThumbnailHeight 1024.0

@class WMWound, WMWoundPhoto, WMPhoto;

@interface WMPhotoManager : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

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
                            wound:(WMWound *)wound;

// patient photo

- (UIImage *)scaleAndCenterPatientPhoto:(UIImage *)photo rect:(CGRect)rect success:(BOOL *)success;

@end

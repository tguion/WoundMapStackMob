//
//  WMPhotoManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPhotoManager.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMUtilities.h"
#import "DictionaryToDataTransformer.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface WMPhotoManager()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) BOOL isIPadIdiom;
@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;

@property (strong, nonatomic) IBOutlet UIView *overlayView;                         // overlayView shown over view through camera
@property (strong, nonatomic) IBOutlet UIImageView *imageView;                      // view to hold woundPhoto.thumbnail or woundPhoto.thumbnailLarge
@property (strong, nonatomic) UIView *tapView;                                      // view that has gesture recognizer
@property (strong, nonatomic) NSTimer *hideOverlayTimer;                            // timer to hide overlay

@property (strong, nonatomic) UIImage *image;                                       // image being processed
@property (readonly, nonatomic) CGSize imageSize;

- (IBAction)handleTap:(UITapGestureRecognizer *)sender;                             // handle tap in overlayView to display last image
- (void)handleHideOverlayTimerAction:(NSTimer *)timer;

@end

@interface WMPhotoManager (PrivateMethods)

- (UIImage *)thumbnailFromImage:(UIImage *)image;

- (UIImage *)resizedImage:(UIImage *)image
                   toSize:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(UIImage *)image
                   toSize:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

- (CGRect)insetFrame:(CGRect)frame toAvoidControls:(NSArray *)subviews;

@end

@implementation WMPhotoManager (PrivateMethods)

- (void)hideOverlayAfterDelay
{
    self.hideOverlayTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                             target:self
                                                           selector:@selector(handleHideOverlayTimerAction:)
                                                           userInfo:nil
                                                            repeats:NO];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Creates a thumbnail image from the current image property. This is
//  |kThumbnailSize| pixels, and it's saved to a PNG file.
//
//  https://github.com/bdewey/Pholio/blob/master/Classes/IPPhoto.m

- (UIImage *)thumbnailFromImage:(UIImage *)image
{
    
    NSURL *imageUrl = [NSURL fileURLWithPath:@"someFileName"];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
    NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                      kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                      [NSNumber numberWithFloat:320.0], kCGImageSourceThumbnailMaxPixelSize,
                                      nil];
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
    UIImage *resizedImage = [UIImage imageWithCGImage:thumbnail];
    CFRelease(thumbnail);
    CFRelease(imageSource);
    return resizedImage;
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(UIImage *)image
                   toSize:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality
{
    BOOL drawTransposed;
    
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:image
                       toSize:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(UIImage *)image
                   toSize:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = image.CGImage;
    CFRetain(imageRef);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                8,
                                                0,
                                                rgbColorSpace,
                                                kCGBitmapByteOrderDefault);
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    CGColorSpaceRelease(rgbColorSpace);
    CFRelease(imageRef);
    
    return newImage;
}

/**
 
 http://stackoverflow.com/questions/13937200/ios-uiimagepickercontroller-strange-crash-on-ios-6
 
 - (UIImage *)scaledCopyOfSize:(CGSize)newSize {
 CGImageRef imgRef = self.CGImage;
 
 CGFloat width = CGImageGetWidth(imgRef);
 CGFloat height = CGImageGetHeight(imgRef);
 
 CGAffineTransform transform = CGAffineTransformIdentity;
 CGRect bounds = CGRectMake(0, 0, width, height);
 if (width > newSize.width || height > newSize.height) {
 CGFloat ratio = width/height;
 if (ratio > 1) {
 bounds.size.width = newSize.width;
 bounds.size.height = bounds.size.width / ratio;
 }
 else {
 bounds.size.height = newSize.height;
 bounds.size.width = bounds.size.height * ratio;
 }
 }
 
 CGFloat scaleRatio = bounds.size.width / width;
 CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
 CGFloat boundHeight;
 UIImageOrientation orient = self.imageOrientation;
 switch(orient) {
 
 case UIImageOrientationUp: //EXIF = 1
 transform = CGAffineTransformIdentity;
 break;
 
 case UIImageOrientationUpMirrored: //EXIF = 2
 transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
 transform = CGAffineTransformScale(transform, -1.0, 1.0);
 break;
 
 case UIImageOrientationDown: //EXIF = 3
 transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
 transform = CGAffineTransformRotate(transform, M_PI);
 break;
 
 case UIImageOrientationDownMirrored: //EXIF = 4
 transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
 transform = CGAffineTransformScale(transform, 1.0, -1.0);
 break;
 
 case UIImageOrientationLeftMirrored: //EXIF = 5
 boundHeight = bounds.size.height;
 bounds.size.height = bounds.size.width;
 bounds.size.width = boundHeight;
 transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
 transform = CGAffineTransformScale(transform, -1.0, 1.0);
 transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
 break;
 
 case UIImageOrientationLeft: //EXIF = 6
 boundHeight = bounds.size.height;
 bounds.size.height = bounds.size.width;
 bounds.size.width = boundHeight;
 transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
 transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
 break;
 
 case UIImageOrientationRightMirrored: //EXIF = 7
 boundHeight = bounds.size.height;
 bounds.size.height = bounds.size.width;
 bounds.size.width = boundHeight;
 transform = CGAffineTransformMakeScale(-1.0, 1.0);
 transform = CGAffineTransformRotate(transform, M_PI / 2.0);
 break;
 
 case UIImageOrientationRight: //EXIF = 8
 boundHeight = bounds.size.height;
 bounds.size.height = bounds.size.width;
 bounds.size.width = boundHeight;
 transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
 transform = CGAffineTransformRotate(transform, M_PI / 2.0);
 break;
 
 default:
 [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
 
 }
 
 if (UIGraphicsBeginImageContextWithOptions) {
 UIGraphicsBeginImageContextWithOptions(bounds.size, NO,
 // 0.0f will scale to 1.0/2.0 depending on if the device has a high-resolution screen
 0.0f);
 } else {
 UIGraphicsBeginImageContext(bounds.size);
 }
 
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
 CGContextScaleCTM(context, -scaleRatio, scaleRatio);
 CGContextTranslateCTM(context, -height, 0);
 }
 else {
 CGContextScaleCTM(context, scaleRatio, -scaleRatio);
 CGContextTranslateCTM(context, 0, -height);
 }
 
 CGContextConcatCTM(context, transform);
 
 CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
 UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 return imageCopy;
 }
 
 */

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.image.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.image.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    return transform;
}

- (CGRect)insetFrame:(CGRect)frame toAvoidControls:(NSArray *)subviews
{
    CGRect rect = frame;
    UIView *targetView = self.imagePickerController.view;
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[UIControl class]]) {
            CGRect subviewRect = [targetView convertRect:subview.frame fromView:subview.superview];
            // Find how much subviewRect overlaps frame
            CGRect intersection = CGRectIntersection(subviewRect, frame);
            // If they don't intersect, continue
            if (CGRectIsNull(intersection)) {
                continue;
            }
            // else figure out where the control is CGRectEdge
            CGRectEdge rectEdge = CGRectMaxXEdge;
            CGFloat chopAmount = intersection.size.width;
            CGPoint controlCenter = [targetView convertPoint:subview.center fromView:subview.superview];
            if (controlCenter.y < CGRectGetHeight(targetView.bounds)/2.0) {
                chopAmount = intersection.size.height;
                rectEdge = CGRectMaxYEdge;
            }
            CGRect r3, throwaway;
            // Chop
            CGRectDivide(rect, &throwaway, &r3, chopAmount, rectEdge);
            rect = r3;
        }
        rect = [self insetFrame:rect toAvoidControls:subview.subviews];
    }
    return rect;
}

@end

@implementation WMPhotoManager

+ (WMPhotoManager *)sharedInstance
{
    static WMPhotoManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMPhotoManager alloc] init];
    });
    return SharedInstance;
}

#pragma mark - Take Photo

- (BOOL)shouldUseCameraForNextPhoto
{
    BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    return (cameraAvailable && !self.usePhotoLibraryForNextPhoto);
}

- (UIImagePickerController *)imagePickerController
{
    if (nil == _imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = self.shouldUseCameraForNextPhoto ? UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
        _imagePickerController.allowsEditing = NO;
    }
    return _imagePickerController;
}

- (WMWoundPhoto *)woundPhoto
{
    WMWoundPhoto *woundPhoto = self.appDelegate.navigationCoordinator.woundPhoto;
    if (nil == woundPhoto) {
        // check if one exists
        woundPhoto = [self.appDelegate.navigationCoordinator.wound lastWoundPhoto];
    }
    return woundPhoto;
}

- (UIView *)overlayView
{
    if (nil == _overlayView) {
        CGRect aFrame = self.imagePickerController.view.bounds;
        _overlayView = [[UIView alloc] initWithFrame:aFrame];
        _overlayView.userInteractionEnabled = YES;
        _overlayView.clipsToBounds = NO;
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_overlayView addSubview:self.imageView];
        [_overlayView addSubview:self.tapView];
    }
    return _overlayView;
}

- (UIView *)tapView
{
    if (nil == _tapView) {
        _tapView = [[UIView alloc] initWithFrame:CGRectZero];
        _tapView.userInteractionEnabled = YES;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _tapView;
}

- (UIImageView *)imageView
{
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.alpha = 0.5;
        _imageView.hidden = YES;
        WMWoundPhoto *woundPhoto = self.woundPhoto;
        if (!self.isIPadIdiom && woundPhoto.landscapeOrientation) {
            _imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            _imageView.transform = CGAffineTransformRotate(self.overlayView.transform, M_PI_2);
        }
        _imageView.image = (self.isIPadIdiom ? woundPhoto.thumbnailLarge:woundPhoto.thumbnail);
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _imageView;
}

- (void)setupImagePicker
{
    // user wants to use the camera interface
    self.imagePickerController.showsCameraControls = YES;
    [self setupOverlay];
}

- (void)setupOverlay
{
    self.overlayView.clipsToBounds = NO;
    // add gesture recognizers
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tapView addGestureRecognizer:tapGestureRecognizer];
    // set the frame so that it will not obstruct the iOS controls
    CGRect frame = self.imagePickerController.view.bounds;
    frame = CGRectInset(frame, 66.0, 66.0);
    self.overlayView.frame = frame;
    self.imageView.frame = self.imagePickerController.view.bounds;
    self.imageView.center = CGPointMake(CGRectGetMidX(self.overlayView.bounds), CGRectGetMidY(self.overlayView.bounds));
    self.tapView.frame = self.overlayView.bounds;
    [self.overlayView bringSubviewToFront:self.tapView];
    // set the overlay
    self.imagePickerController.cameraOverlayView = self.overlayView;
    // DEBUG
    [self performSelector:@selector(delayedPrintViews) withObject:nil afterDelay:2.0];
}

- (void)delayedPrintViews
{
    DLog(@"self.imagePickerController.view.bounds %@, self.overlayView.frame %@", NSStringFromCGRect(self.imagePickerController.view.bounds), NSStringFromCGRect(self.overlayView.frame));
}

#pragma mark - UIImagePickerControllerDelegate

// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSString __autoreleasing *mediaType = (NSString *)[info objectForKey:UIImagePickerControllerMediaType];
	if (![mediaType isEqualToString:(NSString *)kUTTypeImage]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Photo"
															message:@"Make sure you are not in movie mode"
														   delegate:nil
												  cancelButtonTitle:@"Close"
												  otherButtonTitles:nil];
		[alertView show];
		return;
	}
    // else use the edited image if available
    UIImage __autoreleasing *image = info[UIImagePickerControllerEditedImage];
    // if not, grab the original image
    if (nil == image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    if (!image && !assetURL) {
        DLog(@"Cannot retrieve an image from the selected item. Giving up.");
    } else if (!image) {
        DLog(@"Retrieving from Assets Library");
        [self loadImageFromAssetURL:assetURL into:&image];
    }
    // process any metatdata
    NSDictionary __autoreleasing *metadata = info[UIImagePickerControllerMediaMetadata];
    DLog(@"Image metadata: %@", metadata);
    // remove our overlay
    if (self.shouldUseCameraForNextPhoto) {
        picker.cameraOverlayView = nil;
    }
	if (nil != image) {
		[self.delegate photoManager:self didCaptureImage:image metadata:metadata];
	}
    // clear cache
    _overlayView = nil;
    _imageView = nil;
    _tapView = nil;
    _usePhotoLibraryForNextPhoto = NO;
    [_hideOverlayTimer invalidate];
    _hideOverlayTimer = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate photoManagerDidCancelCaptureImage:self];
    // remove our overlay
    if (self.shouldUseCameraForNextPhoto) {
        picker.cameraOverlayView = nil;
    }
    // clear cache
    _overlayView = nil;
    _imageView = nil;
    _tapView = nil;
    _usePhotoLibraryForNextPhoto = NO;
    [_hideOverlayTimer invalidate];
    _hideOverlayTimer = nil;
}

#pragma mark - Gesture handlers

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        // remove last photo if showing
        if (!self.imageView.hidden) {
            self.imageView.hidden = YES;
            [_hideOverlayTimer invalidate];
            _hideOverlayTimer = nil;
            return;
        }
        // else show our image for specified period of time
        WMWoundPhoto *woundPhoto = self.woundPhoto;
        if (nil == woundPhoto) {
            return;
        }
        // else
        self.imageView.hidden = NO;
        // install timer
        [self hideOverlayAfterDelay];
    }
}

- (void)handleHideOverlayTimerAction:(NSTimer *)timer
{
    [_hideOverlayTimer invalidate];
    _hideOverlayTimer = nil;
    self.imageView.hidden = YES;
}

#pragma mark - Core

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)isIPadIdiom
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (CGSize)imageSize
{
    return self.image.size;
}

#pragma mark - Transforms

+ (void)applyTransform:(UIView *)aView forWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    if (woundPhoto.hasTransform) {
        aView.transform = CGAffineTransformScale(aView.transform, [woundPhoto.transformScale floatValue], [woundPhoto.transformScale floatValue]);
        aView.transform = CGAffineTransformRotate(aView.transform, [woundPhoto.transformRotation floatValue]);
        aView.transform = CGAffineTransformTranslate(aView.transform, woundPhoto.translation.x, woundPhoto.translation.y);
    }
}

#pragma mark - Process Photos

- (void)loadImageFromAssetURL:(NSURL *)assetURL into:(UIImage **)image
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryAssetForURLResultBlock resultsBlock = ^(ALAsset *asset)
    {
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        CGImageRef cgImage = [assetRepresentation CGImageWithOptions:nil];
        CFRetain(cgImage); // Thanks Oliver Drobnik
        if (image) *image = [UIImage imageWithCGImage:cgImage];
        CFRelease(cgImage);
    };
    ALAssetsLibraryAccessFailureBlock failure = ^(NSError *__strong error)
    {
        DLog(@"Error retrieving asset from url: %@", error.localizedFailureReason);
    };
    [library assetForURL:assetURL resultBlock:resultsBlock failureBlock:failure];
}

- (void)processNewImage:(UIImage *)image
               metadata:(NSDictionary *)metadata
                  wound:(WMWound *)wound
      completionHandler:(WMObjectCallback)completionHandler;
{
    // DEBUG tiling test
    //    image = [UIImage imageNamed:@"CuriousFrog.jpg"];
    // DEBUG END
    // create and scale in background
    DictionaryToDataTransformer *transformer = [[DictionaryToDataTransformer alloc] init];
    NSManagedObjectContext *managedObjectContext = [[wound managedObjectContext] parentContext];
    __block WMWoundPhoto *woundPhoto = nil;
    [managedObjectContext performBlockAndWait:^{
        WMWound *wound0 = (WMWound *)[wound MR_inContext:managedObjectContext];
        woundPhoto = [WMWoundPhoto createWoundPhotoForWound:wound0];
        [managedObjectContext save:NULL];
    }];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [managedObjectContext performBlock:^{
            WMPhoto *originalPhoto = [woundPhoto fetchOrCreatePhotoForType:PhotoTypeOriginal];
            originalPhoto.photo = image;
            woundPhoto.imageWidth = @(image.size.width);
            woundPhoto.imageHeight = @(image.size.height);
            woundPhoto.imageOrientation = @(image.imageOrientation);
            woundPhoto.metadata = [[NSString alloc] initWithData:[transformer transformedValue:metadata]
                                                        encoding:NSUTF8StringEncoding];
            woundPhoto.landscapeOrientation = ([woundPhoto.imageWidth floatValue] > [woundPhoto.imageHeight floatValue]);
            // scale
            UIImage *thumbnail = nil;
            if (image.size.width > kMaximumThumbnailWidth) {
                CGFloat scale = kMaximumThumbnailWidth/fmaxf(image.size.width, image.size.height);
                CGSize itemSize = CGSizeMake(roundf(scale * image.size.width), roundf(scale * image.size.height));
                UIGraphicsBeginImageContextWithOptions(itemSize, YES, 0.0);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [image drawInRect:imageRect];
                thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            } else {
                thumbnail = image;
            }
            woundPhoto.thumbnail = thumbnail;
            if (image.size.width > kMaximumPadThumbnailWidth) {
                CGFloat scale = kMaximumPadThumbnailWidth/fmaxf(image.size.width, image.size.height);
                CGSize itemSize = CGSizeMake(roundf(scale * image.size.width), roundf(scale * image.size.height));
                UIGraphicsBeginImageContextWithOptions(itemSize, YES, 0.0);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [image drawInRect:imageRect];
                thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            } else {
                thumbnail = image;
            }
            woundPhoto.thumbnailLarge = thumbnail;
            //thumbnailMini
            CGFloat scale = kMaximumThumbnailMiniWidth/fmaxf(image.size.width, image.size.height);
            CGSize itemSize = CGSizeMake(roundf(scale * image.size.width), roundf(scale * image.size.height));
            UIGraphicsBeginImageContextWithOptions(itemSize, YES, 0.0);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [image drawInRect:imageRect];
            thumbnail = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            woundPhoto.thumbnailMini = thumbnail;
            // TODO call back on main thread
            completionHandler(nil, [woundPhoto MR_inContext:[wound managedObjectContext]]);
        }];
    });
}

#pragma mark - Patient Photo

- (UIImage *)scaleAndCenterPatientPhoto:(UIImage *)photo rect:(CGRect)rect success:(BOOL *)success
{
    UIImageOrientation orientientation = photo.imageOrientation;
    UIImage *thumbnail = photo;
    // http://stackoverflow.com/questions/10746212/cidetector-and-uiimagepickercontroller
    int exifOrientation;
    switch (thumbnail.imageOrientation) {
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
        default:
            break;
    }
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:thumbnail.CGImage];//[[CIImage alloc] initWithImage:thumbnail];
    // create a face detector - try low accuracy
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
    // create an array containing all the detected faces from the detector
    NSArray *features = [detector featuresInImage:image
                                          options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]}];
    NSInteger maxResolution = fmaxf(CGRectGetWidth(rect), CGRectGetHeight(rect));
    if (0 == [features count]) {
        // unable to detect face
        *success = NO;
        CGFloat width = CGRectGetWidth(rect);
        if (photo.size.width > width) {
            CGFloat scale = width/fmaxf(photo.size.width, photo.size.height);
            CGSize itemSize = CGSizeMake(roundf(scale * photo.size.width), roundf(scale * photo.size.height));
            UIGraphicsBeginImageContextWithOptions(itemSize, YES, 0.0);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [photo drawInRect:imageRect];
            thumbnail = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return thumbnail;
    }
    // else
    *success = YES;
    CIFaceFeature *faceFeature = [features firstObject];
    CGRect faceRect = faceFeature.bounds;
    CGFloat delta = ceilf(CGRectGetWidth(faceRect)/2.0);
    CGRect faceRectEnlarged = CGRectInset(faceFeature.bounds, -delta, -delta);
    faceRectEnlarged = CGRectIntersection(CGRectMake(0.0, 0.0, photo.size.width, photo.size.height), faceRectEnlarged);
    image = [image imageByCroppingToRect:faceRectEnlarged];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImageRef = [context createCGImage:image fromRect:image.extent];
    thumbnail = [UIImage imageWithCGImage:cgImageRef];
    CFRelease(cgImageRef);
    DLog(@"thumbnail face size %@", NSStringFromCGSize(thumbnail.size));
    return [self scaleAndRotateImage:thumbnail maxResolution:maxResolution imageOrientation:orientientation];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image maxResolution:(NSInteger)maxResolution imageOrientation:(UIImageOrientation)imageOrientation
{
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > maxResolution || height > maxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = maxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = imageOrientation;
    if (imageOrientation < 0) {
        orient = image.imageOrientation;
    }
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end

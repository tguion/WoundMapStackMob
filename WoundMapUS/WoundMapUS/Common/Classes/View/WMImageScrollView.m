//
//  WMImageScrollView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/12/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMImageScrollView.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMPhotoManager.h"
#import "WMNavigationCoordinator.h"
#import "Faulter.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"

@interface WMImageScrollView () <UIScrollViewDelegate> {    
    UIImageView *_zoomView;  // if tiling, this contains a very low-res placeholder image. otherwise it contains the full image.
    CGSize       _imageSize;
    WMTilingView  *_tilingView;
    CGPoint  _pointToCenterAfterResize;
    CGFloat  _scaleToRestoreAfterResize;
}
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMPhotoManager *photoManager;
@property (readonly, nonatomic) BOOL isTiling;

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;

- (void)handleMemoryWarning;
- (void)handleWoundPhotoChanged:(NSManagedObjectID *)woundPhotoObjectID;

@end

@interface WMImageScrollView (PrivateMethods)
- (void)initialize;
@end

@implementation WMImageScrollView (PrivateMethods)

- (void)initialize
{
    self.contentMode = UIViewContentModeScaleToFill;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.zoomScale = self.minimumZoomScale;
    // listen for low memory
    __weak __typeof(&*self)weakSelf = self;
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [weakSelf handleMemoryWarning];
                                                                }];
    [self.opaqueNotificationObservers addObject:observer];
    // woundPhoto was selected
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:kWoundPhotoChangedNotification
                                                                 object:nil
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *notification) {
                                                                 [weakSelf handleWoundPhotoChanged:[notification object]];
                                                             }];
    [self.opaqueNotificationObservers addObject:observer];
}

@end

@implementation WMImageScrollView

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMPhotoManager *)photoManager
{
    return [WMPhotoManager sharedInstance];
}

- (BOOL)isTiling
{
    return NO;
}

- (CGRect)targetFrameInView:(UIView *)aView
{
    CGRect aFrame = [self centeredFrame:_zoomView.frame forBounds:aView.bounds];
    aFrame = [aView convertRect:aFrame fromView:_zoomView.superview];
    return aFrame;
}

- (NSMutableArray *)opaqueNotificationObservers
{
    if (nil == _opaqueNotificationObservers) {
        _opaqueNotificationObservers = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _opaqueNotificationObservers;
}

- (WMWoundPhoto *)woundPhoto
{
    return self.appDelegate.navigationCoordinator.woundPhoto;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (nil == newSuperview) {
        // stop listening
        for (id observer in _opaqueNotificationObservers) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
        _opaqueNotificationObservers = nil;
    } else {
        // view must be in hierarchy at this point
        if (self.isTiling) {
            //DLog(@"%@.setWoundPhoto tiling for image size %@", NSStringFromClass([self class]), NSStringFromCGSize(((UIImage *)woundPhoto.photo.photo).size));
            [self displayTiledImageOfSize:CGSizeMake([self.woundPhoto.imageWidth floatValue], [self.woundPhoto.imageHeight floatValue])];
        } else {
            [self displayImage];
            //DLog(@"%@.setWoundPhoto no tiling for image size %@", NSStringFromClass([self class]), NSStringFromCGSize(((UIImage *)woundPhoto.photo.photo).size));
        }
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.zoomScale = self.minimumZoomScale;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // center the zoom view as it becomes smaller than the size of the screen
    _zoomView.frame = [self centeredFrame:_zoomView.frame];
}

- (CGRect)centeredFrame:(CGRect)frameToCenter
{
    return [self centeredFrame:frameToCenter forBounds:self.bounds];
}

- (CGRect)centeredFrame:(CGRect)frameToCenter forBounds:(CGRect)aBounds
{
    CGSize boundsSize = aBounds.size;
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    } else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    } else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    if (sizeChanging) {
        [self prepareToResize];
    }
    [super setFrame:frame];
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

- (void)handleMemoryWarning
{
    // anything more ???
}

#pragma mark - TilingViewDelegate

- (UIImage *)tileForScale:(CGFloat)scale row:(int)row col:(int)col
{
    __block UIImage *image = nil;
    __weak __typeof(&*self)weakSelf = self;
    [self.managedObjectContext performBlockAndWait:^{
        image = [weakSelf.woundPhoto tileImageForScale:(int)(1000 * scale) row:row column:col];
    }];
    return image;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

#pragma mark - Configure scrollView to display new image (tiled or not)

- (void)displayImage
{
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    // make sure the data is local
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    WMPhoto *photo = self.woundPhoto.photo;
    NSManagedObjectID *woundPhotoID = [self.woundPhoto objectID];
    NSManagedObjectID *photoID = [photo objectID];
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        // make a new UIImageView for the new image
        UIImage *image = photo.photo;
        _zoomView = [[UIImageView alloc] initWithImage:image];
        [weakSelf addSubview:_zoomView];
        [weakSelf configureForImageSize:image.size];
        // fault our cache
        [Faulter faultObjectWithID:photoID inContext:managedObjectContext];
        [Faulter faultObjectWithID:woundPhotoID inContext:managedObjectContext];
    };
    if (nil == photo.photo) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [ff loadBlobsForObj:photo onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [activityIndicatorView removeFromSuperview];
            photo.photo = [[UIImage alloc] initWithData:photo.photo];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            block();
        }];
    } else {
        block();
    }
}

- (void)displayTiledImageOfSize:(CGSize)imageSize
{
    // clear views for the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    _tilingView = nil;
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    // make views to display the new image
    _zoomView = [[UIImageView alloc] initWithFrame:(CGRect){ CGPointZero, imageSize }];
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    [_zoomView setImage:(isPad ? self.woundPhoto.thumbnailLarge:self.woundPhoto.thumbnail)];
    [self addSubview:_zoomView];
    _tilingView = [[WMTilingView alloc] initWithFrame:CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)];
    _tilingView.delegate = self;
    _tilingView.frame = _zoomView.bounds;
    [_zoomView addSubview:_tilingView];
    [self configureForImageSize:imageSize];
}

#pragma mark - Core

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the maximum zoom scale to 0.5.
    CGFloat maxScale = 4.0;//1.0 / [[UIScreen mainScreen] scale];
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    //DLog(@"%@.setMaxMinZoomScalesForCurrentBounds minimumZoomScale:%f maximumZoomScale:%f", NSStringFromClass([self class]), minScale, maxScale);
}

- (void)handleWoundPhotoChanged:(NSManagedObjectID *)woundPhotoObjectID
{
    if (self.isTiling) {
        //DLog(@"%@.setWoundPhoto tiling for image size %@", NSStringFromClass([self class]), NSStringFromCGSize(((UIImage *)woundPhoto.photo.photo).size));
        [self displayTiledImageOfSize:CGSizeMake([self.woundPhoto.imageWidth floatValue], [self.woundPhoto.imageHeight floatValue])];
    } else {
        [self displayImage];
        //DLog(@"%@.setWoundPhoto no tiling for image size %@", NSStringFromClass([self class]), NSStringFromCGSize(((UIImage *)woundPhoto.photo.photo).size));
    }
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, _scaleToRestoreAfterResize));
    
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

@end

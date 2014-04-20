//
//  WMGridImageViewContainer.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/4/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMGridImageViewContainer.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMRoundedSemitransparentLabel.h"
#import "WMDesignUtilities.h"
#import "Faulter.h"
#import "ConstraintPack.h"
#import <QuartzCore/QuartzCore.h>

@interface WMGridImageViewContainer()

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectID *woundPhotoObjectID;
@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;

@end

@implementation WMGridImageViewContainer

@synthesize woundPhoto=_woundPhoto;

- (NSManagedObjectContext *) managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    // listen for low memory
    __weak __typeof(self) weakSelf = self;
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [weakSelf handleMemoryWarning];
                                                                }];
    [self.opaqueNotificationObservers addObject:observer];
}

- (NSMutableArray *)opaqueNotificationObservers
{
    if (nil == _opaqueNotificationObservers) {
        _opaqueNotificationObservers = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _opaqueNotificationObservers;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (nil == newSuperview) {
        _woundPhoto = nil;
        _woundPhotoObjectID = nil;
        // stop listening
        for (id observer in _opaqueNotificationObservers) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
        _opaqueNotificationObservers = nil;;
    }
}

- (void)updateConstraints
{
    // remove constraints
    for (NSLayoutConstraint *constraint in _imageView.referencingConstraints) {
        [constraint remove];
    }
    [super updateConstraints];
    // Limit aspect at high priority
    UIImageView *imageView = _imageView;
    if (nil == imageView) {
        return;
    }
    // else
    UIImage *image = imageView.image;
    NSLayoutConstraint *constraint;
    CGFloat naturalAspect = image.size.width / image.size.height;
    constraint = [NSLayoutConstraint constraintWithItem:imageView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:imageView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:naturalAspect
                                               constant:0];
    [constraint install:1000];
    CenterView(imageView, 1000);
    StretchToSuperview(imageView, 0.0, 251);
    ConstrainToSuperview(imageView, 1000);
    // Lower down compression resistance priority
    RESIST(imageView, 249);
}

- (WMWoundPhoto *)woundPhoto
{
    if (nil == _woundPhoto && nil != _woundPhotoObjectID) {
        _woundPhoto = (WMWoundPhoto *)[self.managedObjectContext objectWithID:_woundPhotoObjectID];
    }
    return _woundPhoto;
}

- (void)setWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    if (_woundPhoto == woundPhoto) {
        return;
    }
    // else
    [self willChangeValueForKey:@"woundPhoto"];
    _woundPhoto = woundPhoto;
    _woundPhotoObjectID = [woundPhoto objectID];
    [self didChangeValueForKey:@"woundPhoto"];
    if (nil == woundPhoto) {
        [_imageView removeFromSuperview];
        _imageView = nil;
        self.dateLabel.hidden = YES;
    } else {
        self.dateLabel.hidden = NO;
        UIImage *image = nil;
        switch (self.displayOption) {
            case WoundPhotoDisplayOptionThumbnail:
                image = woundPhoto.thumbnail;
                break;
            case WoundPhotoDisplayOptionFull:
                image = woundPhoto.photo.photo;
                break;
            case WoundPhotoDisplayOptionTiled:
                image = woundPhoto.thumbnail;
                break;
        }
        [self addImageView:image];
        // update frame
        self.dateLabel.text = [NSDateFormatter localizedStringFromDate:woundPhoto.createdAt
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterMediumStyle];
        [self bringSubviewToFront:self.dateLabel];
        if (self.configureForSlideShow) {
            self.userInteractionEnabled = NO;
            self.opaque = NO;
        }
        if (self.applyWoundPhotoTransform) {
            // apply transform
            if (!woundPhoto.isTransformIdentity) {
                //                DLog(@"imageView.frame before transform: %@", NSStringFromCGRect(self.imageView.frame));
                self.imageView.transform = woundPhoto.transform;
                //                DLog(@"imageView.frame after transform: %@", NSStringFromCGRect(self.imageView.frame));
            } else {
                self.imageView.transform = CGAffineTransformIdentity;
                //                DLog(@"imageView.frame identity transform: %@", NSStringFromCGRect(self.imageView.frame));
            }
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !woundPhoto.landscapeOrientation) {
                self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_2);
            }
        }
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsDisplay];
    // turn our photos into fault
    [Faulter faultObjectWithID:[woundPhoto.photo objectID] inContext:self.managedObjectContext];
    [Faulter faultObjectWithID:[woundPhoto objectID] inContext:self.managedObjectContext];
}

- (void)addImageView:(UIImage *)image
{
    [_imageView removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    // Enable arbitrary image scaling
    imageView.contentMode = UIViewContentModeScaleToFill;
    _imageView = imageView;
    [imageView setNeedsUpdateConstraints];
}

- (void)handleMemoryWarning
{
    _woundPhoto = nil;
}

@end

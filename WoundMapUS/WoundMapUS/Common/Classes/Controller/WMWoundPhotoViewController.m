//
//  WMWoundPhotoViewController.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMWoundPhotoViewController.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMGridImageViewContainer.h"
#import "WMUtilities.h"

@interface WMWoundPhotoViewController ()
@property (weak, nonatomic) IBOutlet WMGridImageViewContainer *imageViewContainer;
@property (strong, nonatomic) WMWoundPhoto *woundPhoto;
@end

@implementation WMWoundPhotoViewController

@synthesize imageViewContainer=_imageViewContainer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set state
    _imageViewContainer.displayOption = WoundPhotoDisplayOptionThumbnail;//(self.isIPadIdiom ? WoundPhotoDisplayOptionFull:WoundPhotoDisplayOptionThumbnail);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // update the view
    _imageViewContainer.woundPhoto = self.woundPhoto;
    [self updateViewConstraints];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _woundPhoto = nil;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [_imageViewContainer.imageView setNeedsUpdateConstraints];
}

#pragma mark - Rotation

// Handle rotation animation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
}

#pragma mark - Core

- (WMWoundPhoto *)woundPhoto
{
    if (nil == _woundPhoto && nil != _woundPhotoObjectID) {
        _woundPhoto = (WMWoundPhoto *)[[NSManagedObjectContext MR_defaultContext] objectWithID:_woundPhotoObjectID];
    }
    return _woundPhoto;
}

- (void)setWoundPhotoObjectID:(NSManagedObjectID *)woundPhotoObjectID
{
    if (_woundPhotoObjectID == woundPhotoObjectID) {
        return;
    }
    // else
    _woundPhotoObjectID = woundPhotoObjectID;
    _imageViewContainer.woundPhoto = self.woundPhoto;
}

#pragma mark - Actions

@end

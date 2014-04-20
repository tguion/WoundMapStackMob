//
//  WMComparePhotosViewController.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/27/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMComparePhotosViewController.h"
#import "WMWoundPhotoCollectionViewCell.h"
#import "WMWoundPhoto.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

@interface WMComparePhotosViewController ()

@end

@interface WMComparePhotosViewController (PrivateMethods)

@end

@implementation WMComparePhotosViewController (PrivateMethods)

@end

@implementation WMComparePhotosViewController

@synthesize leftKalDelegate=_leftKalDelegate, rightKalDelegate=_rightKalDelegate;

- (KalDelegate *)leftKalDelegate
{
    if (nil == _leftKalDelegate) {
        _leftKalDelegate = [[KalDelegate alloc] initWithDelegate:self];
    }
    return _leftKalDelegate;
}

- (KalDelegate *)rightKalDelegate
{
    if (nil == _rightKalDelegate) {
        _rightKalDelegate = [[KalDelegate alloc] initWithDelegate:self];
    }
    return _rightKalDelegate;
}

#pragma mark - View Lifecycle

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // set state
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - Core

- (void)updateCollectionViewLayoutItemSize
{
    UICollectionViewFlowLayout *myLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
        myLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    } else {
        myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (nil == cell) {
        return;
    }
    // else
    cell.contentView.clipsToBounds = YES;
    WMWoundPhotoCollectionViewCell *myCell = (WMWoundPhotoCollectionViewCell *)cell;
    WMWoundPhoto *woundPhoto = nil;
    if (indexPath.row == 0) {
        woundPhoto = self.delegate.woundPhotoDate1;
    } else {
        woundPhoto = self.delegate.woundPhotoDate2;
    }
    myCell.woundPhotoObjectID = [woundPhoto objectID];
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    UICollectionViewFlowLayout *myLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (UIDeviceOrientationIsPortrait(fromInterfaceOrientation)) {
        // now landscape
        myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    } else {
        // now portrait
        myLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
}

#pragma mark - KalDelegateDelegate

- (NSManagedObjectContext *)managedObjectContext
{
    return self.delegate.managedObjectContext;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

- (WMWoundPhoto *)selectedWoundPhoto:(KalDelegate *)kalDelegate
{
    if (_leftKalDelegate == kalDelegate) {
        return self.delegate.woundPhotoDate1;
    }
    // else
    return self.delegate.woundPhotoDate2;
}

- (void)kalDelegate:(KalDelegate *)kalDelegate didLoadWoundPhotosForTable:(NSArray *)woundPhotos
{
}

- (void)kalDelegate:(KalDelegate *)kalDelegate didSelectWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    if (kalDelegate == self.leftKalDelegate) {
        self.delegate.woundPhotoDate1 = woundPhoto;
    } else {
        self.delegate.woundPhotoDate2 = woundPhoto;
    }
    [self.delegate dismissSelectWoundPhotoByDateController];
}

- (void)kalDelegate:(KalDelegate *)kalDelegate didSelectWoundPhotoObjectID:(NSManagedObjectID *)woundPhotoObjectID
{
    if (kalDelegate == self.leftKalDelegate) {
        self.delegate.woundPhotoDate1 = (WMWoundPhoto *)[self.managedObjectContext objectWithID:woundPhotoObjectID];
    } else {
        self.delegate.woundPhotoDate2 = (WMWoundPhoto *)[self.managedObjectContext objectWithID:woundPhotoObjectID];
    }
    [self.delegate dismissSelectWoundPhotoByDateController];
}

- (void)kalDelegateDidCancel:(KalDelegate *)kalDelegate
{
    [self.delegate dismissSelectWoundPhotoByDateController];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGSize aSize = CGSizeZero;
    UICollectionViewFlowLayout *myLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
        // one up, one down
        aSize = CGSizeMake(width, height/2.0 - 8.0);
        myLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    } else {
        aSize = CGSizeMake(width/2.0 - 2.0, height);
        myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return aSize;
}

@end

//
//  WMPhotoGridViewController.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/25/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMPhotoGridViewController.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMWoundPhotoCollectionViewCell.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"

@interface WMPhotoGridViewController ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@end

@interface WMPhotoGridViewController (PrivateMethods)

@end

@implementation WMPhotoGridViewController (PrivateMethods)

@end

@implementation WMPhotoGridViewController

@dynamic appDelegate;

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set state
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure collection view - assume two in row
    [self.collectionView registerClass:[WMWoundPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    self.collectionView.pagingEnabled = NO;
    UICollectionViewFlowLayout *myLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    myLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    myLayout.minimumInteritemSpacing = 1.0;
    // need measurement from back end
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    if (self.isViewLoaded && self.view.window == nil) {
        // Add code to preserve data stored in the views that might be needed later.

        // Add code to clean up other strong references to the view in the view hierarchy.

        self.view = nil;
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Core

- (void)invalidateWoundPhotoCache
{
    [self.delegate invalidateWoundPhotoCache];
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (nil == cell) {
        return;
    }
    // else
    cell.contentView.clipsToBounds = YES;
    WMWoundPhotoCollectionViewCell *myCell = (WMWoundPhotoCollectionViewCell *)cell;
    myCell.woundPhotoObjectID = [self.delegate woundPhotoObjectIDAtIndex:indexPath.row];
}

#pragma mark - UICollectionViewDelegate

 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *cell = [collectionView cellForItemAtIndexPath:indexPath];
    WMWoundPhotoCollectionViewCell *myCell = (WMWoundPhotoCollectionViewCell *)cell;
    CGRect aFrame = [myCell frame];
    aFrame = [self.view.window convertRect:aFrame fromView:myCell.superview];
    [self.delegate handleWoundPhotoObjectIDSelection:myCell.woundPhotoObjectID atFrame:aFrame];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.delegate.woundPhotoCount;
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
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    CGFloat cellWidth = width;
    NSInteger count = self.delegate.woundPhotoCount;
    // maximum columns: iPhone: 2, iPad: 4
    if (count == 2) {
        cellWidth /= 2.0;
    } else if (count <=4) {
        cellWidth /= 2.0;
    } else {
        cellWidth /= (isPad ? 4.0:2.0);
    }
    cellWidth -= 2.0;
    return CGSizeMake(cellWidth, cellWidth);
}

@end

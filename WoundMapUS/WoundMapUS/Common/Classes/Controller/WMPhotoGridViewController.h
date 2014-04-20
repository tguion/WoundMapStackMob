//
//  WMPhotoGridViewController.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/25/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPhotosContainerViewController.h"

@interface WMPhotoGridViewController : UICollectionViewController

@property (weak, nonatomic) id<WoundPhotoCache> delegate;

- (void)invalidateWoundPhotoCache;

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

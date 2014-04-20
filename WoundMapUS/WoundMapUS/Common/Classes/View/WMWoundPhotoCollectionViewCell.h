//
//  WMWoundPhotoCollectionViewCell.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/25/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMWoundPhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSManagedObjectID *woundPhotoObjectID;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

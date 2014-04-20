//
//  WMGridImageViewContainer.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/4/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMWoundPhoto;
@class WMRoundedSemitransparentLabel;

typedef enum {
    WoundPhotoDisplayOptionThumbnail = 0,
    WoundPhotoDisplayOptionFull = 1,
    WoundPhotoDisplayOptionTiled = 2
} WoundPhotoDisplayOption;

@interface WMGridImageViewContainer : UIView

@property (nonatomic) WoundPhotoDisplayOption displayOption;
@property (nonatomic) BOOL applyWoundPhotoTransform;
@property (nonatomic) BOOL configureForSlideShow;
@property (strong, nonatomic) WMWoundPhoto *woundPhoto;

@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet WMRoundedSemitransparentLabel *dateLabel;

@end

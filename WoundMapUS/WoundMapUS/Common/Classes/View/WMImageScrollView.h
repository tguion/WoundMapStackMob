//
//  WMImageScrollView.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/12/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMTilingView.h"

@class WMWoundPhoto;

@interface WMImageScrollView : UIScrollView <TilingViewDelegate>

@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;

- (CGRect)targetFrameInView:(UIView *)aView;         // initial frame of zoomed image

@end

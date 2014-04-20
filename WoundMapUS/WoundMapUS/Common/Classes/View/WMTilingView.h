//
//  WMTilingView.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/12/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TilingViewDelegate <NSObject>

- (UIImage *)tileForScale:(CGFloat)scale row:(int)row col:(int)col;

@end

@interface WMTilingView : UIView

@property (weak, nonatomic) id<TilingViewDelegate>delegate;

@end

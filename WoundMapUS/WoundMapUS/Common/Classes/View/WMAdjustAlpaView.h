//
//  WMAdjustAlpaView.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/20/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kInitialBackgroundImageAlpha;

@class WMAdjustAlpaView;

@protocol AdjustAlpaViewDelegate <NSObject>

@property (readonly, nonatomic) CGFloat initialAlpha;
- (void)adjustAlpaView:(WMAdjustAlpaView *)adjustAlpaView didUpdateAlpha:(CGFloat)alpha;

@end

@interface WMAdjustAlpaView : UIView

@property (weak, nonatomic) id<AdjustAlpaViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<AdjustAlpaViewDelegate>)delegate;
- (void)reset;

@end

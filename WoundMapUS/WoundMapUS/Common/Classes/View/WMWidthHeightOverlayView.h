//
//  WMWidthHeightOverlayView.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 9/19/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

@class WMWidthHeightOverlayView;

@protocol WidthHeightOverlayViewDelegate <NSObject>

- (void)widthHeightOverlayView:(WMWidthHeightOverlayView *)widthHeightOverlayView didUpdateWoundRect:(CGRect)woundRect;

@end

@interface WMWidthHeightOverlayView : UIView

@property (weak, nonatomic) IBOutlet id<WidthHeightOverlayViewDelegate> delegate;

@property (nonatomic) CGFloat boxOffset;
@property (nonatomic) CGFloat pointsPerCentimeter;
@property (nonatomic) CGPoint translationDelta;
@property (nonatomic) BOOL resetCalled;
@property (readonly, nonatomic) CGRect woundRect;

- (void)resetWithPointsPerCentemeter:(CGFloat)pointsPerCentemeter;

@end

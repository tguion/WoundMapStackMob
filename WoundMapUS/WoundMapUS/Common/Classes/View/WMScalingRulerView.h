//
//  WMScalingRulerView.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 8/7/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMScalingRulerView : UIView

@property (nonatomic) CGFloat boxOffset;
@property (nonatomic) CGFloat scaleFactor;
@property (readonly, nonatomic) CGFloat pointsPerCentimeter;

- (void)reset;  // protocol

@end

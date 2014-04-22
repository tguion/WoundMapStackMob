//
//  WMDimensionView.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/17/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMDimensionView : UIView

- (void)updateForRect:(CGRect)woundRect pointsPerCentimeter:(CGFloat)pointsPerCentimeter transform:(CGAffineTransform)transform;

@end

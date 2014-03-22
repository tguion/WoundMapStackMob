//
//  WMBradenScaleTableHeaderView.h
//  WoundCare
//
//  Created by Todd Guion on 8/3/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMBradenScale;

@interface WMBradenScaleTableHeaderView : UIView

@property (strong, nonatomic) WMBradenScale *bradenScale;

- (CGFloat)recommendedHeight;

@end

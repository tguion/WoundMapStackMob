//
//  WMNavigationNodeButton.h
//  WoundPUMP
//
//  Created by Todd Guion on 7/19/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCompassView.h"

@class WMNavigationNode;

@interface WMNavigationNodeButton : UIButton

@property (nonatomic) MapBaseRotationDirection rotationDirection;
@property (strong, nonatomic) WMNavigationNode *navigationNode;
@property (nonatomic) NSInteger complianceDelta;
@property (readonly, weak, nonatomic) UIImageView *iconImageView;
@property (nonatomic) NSInteger recentlyClosedCount;

- (id)initWithNavigationNode:(WMNavigationNode *)navigationNode rotationDirection:(MapBaseRotationDirection)rotationDirection;

@end

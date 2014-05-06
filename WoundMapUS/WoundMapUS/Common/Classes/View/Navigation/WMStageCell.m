//
//  WMStageCell.m
//  WoundMAP
//
//  Created by etreasure consulting LLC on 11/20/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMStageCell.h"

@interface WMStageCell ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation WMStageCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _segmentedControl.center = center;
}

@end

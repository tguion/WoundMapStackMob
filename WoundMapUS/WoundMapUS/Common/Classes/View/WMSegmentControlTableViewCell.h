//
//  WMSegmentControlTableViewCell.h
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSegmentControlTableViewCell : UITableViewCell

@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;

- (void)configureWithItems:(NSArray *)items target:(__weak id)target action:(SEL)action;

@end

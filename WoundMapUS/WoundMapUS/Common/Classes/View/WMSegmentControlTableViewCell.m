//
//  WMSegmentControlTableViewCell.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMSegmentControlTableViewCell.h"

@implementation WMSegmentControlTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegmentedCell"];
    if (self) {
        // Initialization code
        UIView *contentView = self.contentView;
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:segmentedControl];
        _segmentedControl = segmentedControl;
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_segmentedControl
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:contentView
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_segmentedControl
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:contentView
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0]];
        NSDictionary *views = NSDictionaryOfVariableBindings(_segmentedControl);
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_segmentedControl]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [contentView addConstraints:constraints];
    }
    return self;
}

- (void)configureWithItems:(NSArray *)items target:(__weak id)target action:(SEL)action
{
    _target = target;
    _action = action;
    [_segmentedControl removeAllSegments];
    NSUInteger segment = 0;
    for (NSString *title in items) {
        [_segmentedControl insertSegmentWithTitle:title atIndex:segment++ animated:NO];
    }
    [_segmentedControl addTarget:_target action:action forControlEvents:UIControlEventValueChanged];
}

@end

//
//  WMButtonCell.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/19/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMButtonCell.h"

@implementation WMButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *contentView = self.contentView;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.contentView addSubview:button];
        _button = button;
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_button);
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_button]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_button]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [contentView addConstraints:constraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  WMSwitchTableViewCell.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/9/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMSwitchTableViewCell.h"

@interface WMSwitchTableViewCell ()

@property (weak, nonatomic) id target;
@property (weak, nonatomic) UISwitch *aSwitch;

@end

@implementation WMSwitchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *contentView = self.contentView;
        
        [contentView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        UILabel *textLabel = self.textLabel;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [textLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(textLabel);
        NSDictionary *metrics = @{@"Left" : @(self.separatorInset.left)};

        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textLabel]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[textLabel]|" options:NSLayoutFormatAlignAllLeading metrics:metrics views:views]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [contentView addConstraints:constraints];

        UISwitch *aSwitch = [[UISwitch alloc] init];
        self.accessoryView = aSwitch;
        _aSwitch = aSwitch;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithLabelText:(NSString *)labelText value:(BOOL)value target:(id)target action:(SEL)action tag:(NSInteger)tag
{
    self.textLabel.text = labelText;
    _aSwitch.on = value;
    [_aSwitch addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    _aSwitch.tag = tag;
}


@end

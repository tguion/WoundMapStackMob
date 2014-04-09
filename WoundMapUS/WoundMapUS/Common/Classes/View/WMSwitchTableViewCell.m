//
//  WMSwitchTableViewCell.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
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
    [self.textLabel sizeToFit];
    _aSwitch.on = value;
    [_aSwitch addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    _aSwitch.tag = tag;
}


@end

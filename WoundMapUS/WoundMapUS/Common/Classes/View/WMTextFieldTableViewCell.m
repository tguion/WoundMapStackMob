//
//  WMTextFieldTableViewCell.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/17/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTextFieldTableViewCell.h"

@interface WMTextFieldTableViewCell ()
@property (readwrite, nonatomic) UITextField *textField;
@end

@implementation WMTextFieldTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *contentView = self.contentView;
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(contentView);
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:viewsDictionary]];
        [self addConstraints:constraints];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:textField];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        constraints = [NSMutableArray array];
        UILabel *textLabel = self.textLabel;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        viewsDictionary = NSDictionaryOfVariableBindings(textLabel, textField);
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[textLabel]-[textField]-(8)-|"
                                                                                 options:NSLayoutFormatAlignAllBaseline
                                                                                 metrics:nil
                                                                                   views:viewsDictionary]];
        [self.contentView addConstraints:constraints];
        _textField = textField;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithLabelText:(NSString *)labelText valueText:(NSString *)valueText
{
    self.textLabel.text = labelText;
    [self.textLabel sizeToFit];
    _textField.text = valueText;
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints
{
    [super updateConstraints];
    NSLog(@"contentView %@", self.contentView);
}

@end

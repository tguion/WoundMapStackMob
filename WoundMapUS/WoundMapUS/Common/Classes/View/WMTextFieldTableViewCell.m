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
        UIView *contentView = self.contentView;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:textField];
        _textField = textField;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.textAlignment = NSTextAlignmentRight;
        
        UILabel *textLabel = self.textLabel;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [textLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        NSDictionary *views = NSDictionaryOfVariableBindings(textLabel, textField);

        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textLabel]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[textLabel]-[textField]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.contentView addConstraints:constraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithLabelText:(NSString *)labelText valueText:(NSString *)valueText valuePrompt:(NSString *)promptText
{
    self.textLabel.text = labelText;
    [self.textLabel sizeToFit];
    _textField.text = valueText;
    _textField.placeholder = promptText;
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self performSelector:@selector(delayedLog) withObject:nil afterDelay:1.0];
}

- (void)delayedLog
{
    NSLog(@"contentView %@", self.contentView);
    NSLog(@"contentView.subviews %@", self.contentView.subviews);
}

@end

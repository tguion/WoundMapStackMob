//
//  WMTextViewTableViewCell.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTextViewTableViewCell.h"
#import "WMRoundedTextView.h"

@interface WMTextViewTableViewCell ()

@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UITextView *textView;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation WMTextViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *contentView = self.contentView;
        
        [contentView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [contentView addSubview:promptLabel];
        _promptLabel = promptLabel;
        promptLabel.translatesAutoresizingMaskIntoConstraints = NO;

        UITextView *textView = [[WMRoundedTextView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:textView];
        _textView = textView;
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return self;
}

- (NSString *)textViewText
{
    return _textView.text;
}

- (void)setTextViewText:(NSString *)textViewText
{
    _textView.text = textViewText;
}

- (void)updateConstraints
{
    if (_constraints) {
        [super updateConstraints];
        return;
    }
    
    UIView *contentView = self.contentView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_promptLabel, _textView);
    NSDictionary *metrics = @{
                              @"Left" : @(self.separatorInset.left),
                              @"Right" : @(8),
                              @"Top" : @(8),
                              @"Bottom" : @(8)
                              };

    NSMutableArray *constraints = [NSMutableArray array];
    if (_promptLabel.superview) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_promptLabel][_textView]|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_promptLabel]-(>=8)-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_textView]-Right-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    } else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-Top-[_textView]-Bottom-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_textView]-Right-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    }
    [contentView addConstraints:constraints];
    [super updateConstraints];
}

- (void)updateWithPrompt:(NSString *)prompt message:(NSString *)message
{
    if (nil == prompt) {
        [_promptLabel removeFromSuperview];
    } else {
        _promptLabel.text = prompt;
    }
    _textView.text = message;
    [self updateConstraintsIfNeeded];
}

@end

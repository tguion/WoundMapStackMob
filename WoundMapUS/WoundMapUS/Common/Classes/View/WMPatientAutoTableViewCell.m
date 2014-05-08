//
//  WMPatientAutoTableViewCell.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/8/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientAutoTableViewCell.h"
#import "WMPatientPhotoImageView.h"
#import "WMPatient.h"
#import "WMPerson.h"
#import "WMPatientConsultant.h"
#import "WMPatientReferral.h"

@interface WMPatientAutoTableViewCell ()

@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) WMPatientPhotoImageView *thumbnailImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *identifierLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIButton *referralButton;

@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation WMPatientAutoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *contentView = self.contentView;
        
        [contentView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        _thumbnailImageView = [[WMPatientPhotoImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 57.0, 57.0)];
        _thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailImageView.image = [WMPatient missingThumbnailImage];
        [contentView addSubview:_thumbnailImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        [contentView addSubview:_titleLabel];
        
        _identifierLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _identifierLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _identifierLabel.font = [UIFont systemFontOfSize:12.0];
        [contentView addSubview:_identifierLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _statusLabel.font = [UIFont systemFontOfSize:12.0];
        [contentView addSubview:_statusLabel];
        
        _referralButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _referralButton.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:_referralButton];
        
    }
    return self;
}

- (void)updateConstraints
{
    if (_constraints) {
        [super updateConstraints];
        return;
    }
    
    UIView *contentView = self.contentView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_thumbnailImageView, _titleLabel, _identifierLabel, _statusLabel, _referralButton);
    NSDictionary *metrics = @{
                              @"Left" : @(self.separatorInset.left),
                              @"Right" : @(8),
                              @"Top" : @(8),
                              @"Bottom" : @(8)
                              };
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_thumbnailImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [_thumbnailImageView addConstraint:[NSLayoutConstraint constraintWithItem:_thumbnailImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:57.0]];
    [_thumbnailImageView addConstraint:[NSLayoutConstraint constraintWithItem:_thumbnailImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:57.0]];

    if (_referralButton.superview) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView]-[_titleLabel]-[_referralButton]-Right-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView]-[_identifierLabel]-[_referralButton]-Right-|" options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView]-[_statusLabel]-[_referralButton]-Right-|" options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_referralButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel]-[_identifierLabel]-[_statusLabel]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    } else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView]-[_titleLabel]-Right-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView]-[_identifierLabel]-Right-|" options:NSLayoutFormatDirectionLeftToRight metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView]-[_statusLabel]-Right-|" options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel]-[_identifierLabel]-[_statusLabel]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    }
    [contentView addConstraints:constraints];
    [super updateConstraints];
    [_thumbnailImageView setNeedsDisplay];
}

- (void)updateForPatient:(WMPatient *)patient patientReferral:(WMPatientReferral *)patientReferral
{
    _constraints = nil;
    UIView *contentView = self.contentView;
    if (patientReferral) {
        if (nil == _referralButton.superview) {
            [contentView addSubview:_referralButton];
            // update button image
            [_referralButton setTitle:@"Referral" forState:UIControlStateNormal];
            [_referralButton sizeToFit];
        }
    } else {
        [_referralButton removeFromSuperview];
    }
    [_thumbnailImageView updateForPatient:patient];
    _titleLabel.text = patient.lastNameFirstName;
    if ([patient.identifierEMR length]) {
        _identifierLabel.text = patient.identifierEMR;
    } else {
        _identifierLabel.text = @"No identifier";
    }
    _statusLabel.text = patient.patientStatusMessages;
    [self updateConstraintsIfNeeded];
//    [self performSelector:@selector(debugSubviews) withObject:nil afterDelay:1.0];
}

- (void)updateForPatientConsultant:(WMPatientConsultant *)patientConsultant
{
    [self updateForPatient:patientConsultant.patient patientReferral:nil];
}

// DEBUG

- (void)debugSubviews
{
    NSLog(@"contentView: %@", self.contentView);
    NSLog(@"subviews: %@", self.contentView.subviews);
}

@end

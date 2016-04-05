//
//  WMPatientAutoTableViewCell.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/8/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
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
@property (strong, nonatomic) UIView *labelContainerView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *identifierLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIButton *referralButton;
@property (strong, nonatomic) UIButton *unarchiveButton;
@property (strong, nonatomic) UIView *topSpacerView;
@property (strong, nonatomic) UIView *bottomSpacerView;

@property (strong, nonatomic) WMPatientReferralCallback referralCallback;
@property (strong, nonatomic) WMPatientUnarchiveCallback unarchiveCallback;

@property (nonatomic, strong) NSMutableArray *constraints;
@property (nonatomic, strong) NSMutableArray *labelsConstraints;

@end

@implementation WMPatientAutoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *contentView = self.contentView;
        
//        [contentView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        _thumbnailImageView = [[WMPatientPhotoImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 57.0, 57.0)];
        _thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailImageView.image = [WMPatient missingThumbnailImage];
        [contentView addSubview:_thumbnailImageView];
        
        _labelContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _labelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:_labelContainerView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_labelContainerView addSubview:_titleLabel];
        
        _identifierLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _identifierLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _identifierLabel.font = [UIFont systemFontOfSize:12.0];
        [_labelContainerView addSubview:_identifierLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _statusLabel.font = [UIFont systemFontOfSize:12.0];
        _statusLabel.numberOfLines = 0;
        [_labelContainerView addSubview:_statusLabel];
        
        _referralButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _referralButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_referralButton setTitle:@"Referral" forState:UIControlStateNormal];
        [_referralButton sizeToFit];
        [_referralButton addTarget:self action:@selector(referralAction:) forControlEvents:UIControlEventTouchUpInside];
        _referralButton.hidden = YES;
        [contentView addSubview:_referralButton];
        [_referralButton setContentCompressionResistancePriority:(UILayoutPriorityDefaultHigh + 1) forAxis:UILayoutConstraintAxisHorizontal];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_referralButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

        _unarchiveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _unarchiveButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_unarchiveButton setTitle:@"Unarchive" forState:UIControlStateNormal];
        [_unarchiveButton sizeToFit];
        [_unarchiveButton addTarget:self action:@selector(unarchiveAction:) forControlEvents:UIControlEventTouchUpInside];
        _unarchiveButton.hidden = YES;
        [contentView addSubview:_unarchiveButton];
        [_unarchiveButton setContentCompressionResistancePriority:(UILayoutPriorityDefaultHigh + 1) forAxis:UILayoutConstraintAxisHorizontal];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_unarchiveButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

        _topSpacerView = [[UIView alloc] initWithFrame:CGRectZero];
        _topSpacerView.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:_topSpacerView];
        
        _bottomSpacerView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomSpacerView.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:_bottomSpacerView];
        
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_thumbnailImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [_thumbnailImageView addConstraint:[NSLayoutConstraint constraintWithItem:_thumbnailImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:57.0]];
        [_thumbnailImageView addConstraint:[NSLayoutConstraint constraintWithItem:_thumbnailImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:57.0]];

        _labelsConstraints = [NSMutableArray array];
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _identifierLabel, _statusLabel);
        [_labelsConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleLabel]-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
        [_labelsConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_identifierLabel]-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
        [_labelsConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_statusLabel]-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
        [_labelsConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel][_identifierLabel][_statusLabel]-(>=8)-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
        [_labelContainerView addConstraints:_labelsConstraints];

    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.accessoryView = nil;
    _referralCallback = nil;
    _unarchiveCallback = nil;
}

//- (void)setNeedsUpdateConstraints
//{
//    if (_constraints) {
//        [self.contentView removeConstraints:_constraints];
//        [_labelContainerView removeConstraints:_labelsConstraints];
//    }
//    _constraints = nil;
//    _labelsConstraints = nil;
//    [super setNeedsUpdateConstraints];
//}

- (void)refreshConstraintsForPatient:(WMPatient *)patient withReferral:(BOOL)referral
{
    UIView *contentView = self.contentView;

    if (_constraints) {
        [self.contentView removeConstraints:_constraints];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_topSpacerView, _thumbnailImageView, _labelContainerView, _bottomSpacerView, _unarchiveButton, _referralButton);
    NSDictionary *metrics = @{
                              @"Left" : @(self.separatorInset.left),
                              @"Right" : @(8),
                              @"Top" : @(8),
                              @"Bottom" : @(8)
                              };
    
    _constraints = [NSMutableArray array];

    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topSpacerView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomSpacerView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    if (patient.archivedFlagValue) {
        _unarchiveButton.hidden = NO;
        [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView][_labelContainerView]-[_unarchiveButton]-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    } else if (referral) {
        _referralButton.hidden = NO;
        [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView][_labelContainerView]-[_referralButton]-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    } else {
        _unarchiveButton.hidden = YES;
        _referralButton.hidden = YES;
        [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_thumbnailImageView][_labelContainerView]|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    }
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topSpacerView][_labelContainerView][_bottomSpacerView(_topSpacerView)]|" options:0 metrics:metrics views:views]];
    
    [contentView addConstraints:_constraints];
    
    [_thumbnailImageView setNeedsDisplay];
}

- (void)updateForPatient:(WMPatient *)patient
         patientReferral:(WMPatientReferral *)patientReferral
        referralCallback:(WMPatientReferralCallback)referralCallback
       unarchiveCallback:(WMPatientUnarchiveCallback)unarchiveCallback
{
    [_thumbnailImageView updateForPatient:patient];
    _titleLabel.text = patient.lastNameFirstName;
    if ([patient.identifierEMR length]) {
        _identifierLabel.text = patient.identifierEMR;
    } else {
        _identifierLabel.text = @"No identifier";
    }
    _statusLabel.text = patient.patientStatusMessages;
    [self refreshConstraintsForPatient:patient withReferral:(patientReferral != nil)];
    [self layoutIfNeeded];
//    [self performSelector:@selector(debugSubviews) withObject:nil afterDelay:1.0]; // DEBUG
    _referralCallback = [referralCallback copy];
    _unarchiveCallback = [unarchiveCallback copy];
}

- (void)updateForPatientConsultant:(WMPatientConsultant *)patientConsultant
{
    [self updateForPatient:patientConsultant.patient patientReferral:nil referralCallback:nil unarchiveCallback:nil];
}

#pragma mark - Actions

- (IBAction)referralAction:(id)sender
{
    if (_referralCallback) {
        _referralCallback(self);
        self.accessoryView = nil;
    }
}

- (IBAction)unarchiveAction:(id)sender
{
    if (_unarchiveCallback) {
        _unarchiveCallback(self);
        self.accessoryView = nil;
    }
}

- (void)debugSubviews
{
    NSLog(@"contentView: %@", self.contentView);
    NSLog(@"subviews: %@", self.contentView.subviews);
    NSLog(@"label container subviews: %@", _labelContainerView.subviews);
}

@end

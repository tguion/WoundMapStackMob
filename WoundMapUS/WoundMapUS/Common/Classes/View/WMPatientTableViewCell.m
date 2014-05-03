//
//  WMPatientTableViewCell.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//
//  Display WMPatient from local index database.
//
//  Consider receiving UIApplicationDidReceiveMemoryWarningNotification notification to close visible documents.

#import "WMPatientTableViewCell.h"
#import "WMPatientPhotoImageView.h"
#import "WMPatient.h"
#import "WMPerson.h"
#import "WMPatientConsultant.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMPatientTableViewCell()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (strong, nonatomic) WMPatientReferral *patientReferral;

@property (weak, nonatomic) UIActivityIndicatorView *activityView;
@property (weak, nonatomic) WMPatientPhotoImageView *thumbnailImageView;

@property (readonly, nonatomic) NSDictionary *titleAttributes;
@property (readonly, nonatomic) NSDictionary *identifierAttributes;
@property (readonly, nonatomic) NSDictionary *statusAttributes;
@property (readonly, nonatomic) NSDictionary *titleSelectedAttributes;
@property (readonly, nonatomic) NSDictionary *identifierSelectedAttributes;
@property (readonly, nonatomic) NSDictionary *statusSelectedAttributes;

@end

@implementation WMPatientTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _patient = nil;
    _patientConsultant = nil;
    _patientReferral = nil;
    [_activityView stopAnimating];
    _thumbnailImageView.image = nil;
}

#pragma mark - Text Attributes

- (NSDictionary *)titleAttributes
{
    static NSDictionary *DocumentTableViewCellTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DocumentTableViewCellTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                               [UIColor blackColor], NSForegroundColorAttributeName,
                                               paragraphStyle, NSParagraphStyleAttributeName,
                                               nil];
    });
    return DocumentTableViewCellTitleAttributes;
}

- (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *DocumentTableViewCellTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DocumentTableViewCellTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                                [UIColor blackColor], NSForegroundColorAttributeName,
                                                paragraphStyle, NSParagraphStyleAttributeName,
                                                nil];
    });
    return DocumentTableViewCellTitleSelectedAttributes;
}

- (NSDictionary *)identifierAttributes
{
    static NSDictionary *DocumentTableViewCellIdentifierAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DocumentTableViewCellIdentifierAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                [UIColor blackColor], NSForegroundColorAttributeName,
                                                paragraphStyle, NSParagraphStyleAttributeName,
                                                nil];
    });
    return DocumentTableViewCellIdentifierAttributes;
}

- (NSDictionary *)identifierSelectedAttributes
{
    static NSDictionary *DocumentTableViewCellIdentifierSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DocumentTableViewCellIdentifierSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                                     paragraphStyle, NSParagraphStyleAttributeName,
                                                     nil];
    });
    return DocumentTableViewCellIdentifierSelectedAttributes;
}

- (NSDictionary *)statusAttributes
{
    static NSDictionary *DocumentTableViewCellStatusAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DocumentTableViewCellStatusAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIFont systemFontOfSize:9.0], NSFontAttributeName,
                                                             [UIColor grayColor], NSForegroundColorAttributeName,
                                                             paragraphStyle, NSParagraphStyleAttributeName,
                                                             nil];
    });
    return DocumentTableViewCellStatusAttributes;
}

- (NSDictionary *)statusSelectedAttributes
{
    static NSDictionary *DocumentTableViewCellStatusSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DocumentTableViewCellStatusSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont systemFontOfSize:9.0], NSFontAttributeName,
                                                 [UIColor whiteColor], NSForegroundColorAttributeName,
                                                 paragraphStyle, NSParagraphStyleAttributeName,
                                                 nil];
    });
    return DocumentTableViewCellStatusSelectedAttributes;
}

#pragma mark - Core

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)setPatient:(WMPatient *)patient
{
    if (_patient == patient) {
        return;
    }
    // set new value
    [self willChangeValueForKey:@"patient"];
    _patient = patient;
    [self didChangeValueForKey:@"patient"];
    // update view
    [_thumbnailImageView updateForPatient:patient];
    [self setNeedsDisplay];
}

- (void)setPatientConsultant:(WMPatientConsultant *)patientConsultant
{
    if (_patientConsultant == patientConsultant) {
        return;
    }
    // set new value
    [self willChangeValueForKey:@"patientConsultant"];
    _patientConsultant = patientConsultant;
    [self didChangeValueForKey:@"patientConsultant"];
    self.patient = patientConsultant.patient;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_patient) {
        return [_patient managedObjectContext];
    }
    // else
    return [_patientConsultant managedObjectContext];
}

- (UIActivityIndicatorView *)activityView
{
    if (nil == _activityView) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.tag = 1000;
        activityIndicatorView.hidesWhenStopped = YES;
        [self.customContentView addSubview:activityIndicatorView];
        _activityView = activityIndicatorView;
    }
    return _activityView;
}

- (WMPatientPhotoImageView *)thumbnailImageView
{
    if (nil == _thumbnailImageView) {
        CGFloat x = 8.0;
        CGFloat y = roundf((CGRectGetHeight(self.bounds) - 57.0)/2.0);
        // insert thumbnailImageView  
        WMPatientPhotoImageView *anImageView = [[WMPatientPhotoImageView alloc] initWithFrame:CGRectMake(x, y, 57.0, 57.0)];
        anImageView.contentScaleFactor = [[UIScreen mainScreen] scale];
        anImageView.clipsToBounds = YES;
        anImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.customContentView addSubview:anImageView];
        _thumbnailImageView = anImageView;
    }
    return _thumbnailImageView;
}

#pragma mark - Manage notifications

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (nil == newSuperview) {
        _patient = nil;
        _patientConsultant = nil;
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self.thumbnailImageView updateForPatient:_patient];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    // get image dimensions and find point to draw it
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat x = CGRectGetMinX(UIEdgeInsetsInsetRect(self.customContentView.frame, self.separatorInset));
    CGFloat y = roundf((height - 57.0)/2.0);
    // position thumbnailImageView  
    self.thumbnailImageView.frame = CGRectMake(x, y, 57.0, 57.0);
}

#pragma mark - Drawing

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    NSDictionary *textAttributes = nil;
    CGFloat width = CGRectGetWidth(rect);
    WMPatient *patient = _patient;
    if (nil == patient) {
        patient = _patientConsultant.patient;
    }
    NSString *string = patient.lastNameFirstName;
    if (self.isHighlightedOrSelected) {
        textAttributes = self.titleSelectedAttributes;
    } else {
        textAttributes = self.titleAttributes;
    }
    CGFloat textXOffset = (nil == self.thumbnailImageView ? 16.0:8.0);
    CGFloat textYOffset = (nil == self.thumbnailImageView ? 8.0:0.0);
    CGFloat x = CGRectGetMaxX(self.thumbnailImageView.frame) + textXOffset;
    CGFloat y = CGRectGetMinY(self.thumbnailImageView.frame) + textYOffset;
    CGFloat lineWidth = (width - x - 4.0);
    CGSize aSize = [string sizeWithAttributes:textAttributes];
    CGRect textRect = CGRectMake(x, y, lineWidth, ceilf(aSize.height));
    [string drawInRect:textRect withAttributes:textAttributes];
    textRect.origin.y += CGRectGetHeight(textRect);
    // draw identifierEMR on next line
    if (self.isHighlightedOrSelected) {
        textAttributes = self.identifierSelectedAttributes;
    } else {
        textAttributes = self.identifierAttributes;
    }
    string = patient.identifierEMR;
    if ([string length] > 0) {
        [string drawInRect:textRect withAttributes:textAttributes];
        textRect.origin.y += CGRectGetHeight(textRect);
    }
    // draw patient status
    if (self.isHighlightedOrSelected) {
        textAttributes = self.statusSelectedAttributes;
    } else {
        textAttributes = self.statusAttributes;
    }
    string = patient.patientStatusMessages;
    if (_patientConsultant) {
        string = _patientConsultant.consultingDescription;
    } else {
        // check if submitted for consult
        if ([patient.patientConsultants count]) {
            string = [NSString stringWithFormat:@"Submitted for consult to %@", [patient valueForKeyPath:@"patientConsultants.consultant.name"]];
        }
    }
    if ([string length] > 0) {
        [string drawInRect:textRect withAttributes:textAttributes];
    }
}

@end

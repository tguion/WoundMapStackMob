//
//  WMNavigationPatientWoundView.m
//  WoundPUMP
//
//  Created by Todd Guion on 8/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMNavigationPatientWoundView.h"
#import "WMNavigationNodeButton.h"
#import "WMPatient.h"
#import "WMWound.h"
//#import "WMWoundLocation.h"
#import "WMNavigationStage.h"
#import "WMNavigationCoordinator.h"
#import "CoreDataHelper.h"
#import "WMDesignUtilities.h"
#import "WCAppDelegate.h"

@interface WMNavigationPatientWoundView ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) BOOL isIPadIdiom;
@property (readonly, nonatomic) WMPatient *patient;
@property (readonly, nonatomic) WMWound *wound;

@property (weak, nonatomic) IBOutlet UIButton *showPatientButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSDictionary *patientTextAttributes;
@property (strong, nonatomic) NSDictionary *woundTextAttributes;
@property (strong, nonatomic) NSDictionary *noWoundTextAttributes;
@property (strong, nonatomic) NSDictionary *stageTextAttributes;

@end

@implementation WMNavigationPatientWoundView

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)isIPadIdiom
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

- (NSDictionary *)patientTextAttributes
{
    if (nil == _patientTextAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        _patientTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont boldSystemFontOfSize:(self.isIPadIdiom ? 24.0:17.0)], NSFontAttributeName,
                                  [UIColor blackColor], NSForegroundColorAttributeName,
                                  paragraphStyle, NSParagraphStyleAttributeName,
                                  nil];
    }
    return _patientTextAttributes;
}

- (NSDictionary *)woundTextAttributes
{
    if (nil == _woundTextAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        _woundTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:(self.isIPadIdiom ? 17.0:13.0)], NSFontAttributeName,
                                [UIColor darkGrayColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    }
    return _woundTextAttributes;
}

- (NSDictionary *)noWoundTextAttributes
{
    if (nil == _noWoundTextAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        _noWoundTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:(self.isIPadIdiom ? 15.0:9.0)], NSFontAttributeName,
                                  [UIColor grayColor], NSForegroundColorAttributeName,
                                  paragraphStyle, NSParagraphStyleAttributeName,
                                  nil];
    }
    return _noWoundTextAttributes;
}

- (NSDictionary *)stageTextAttributes
{
    if (nil == _stageTextAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        _stageTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:(self.isIPadIdiom ? 15.0:9.0)], NSFontAttributeName,
                                  [UIColor lightGrayColor], NSForegroundColorAttributeName,
                                  paragraphStyle, NSParagraphStyleAttributeName,
                                  nil];
    }
    return _stageTextAttributes;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (nil == _activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_activityIndicatorView];
        [_activityIndicatorView stopAnimating];
    }
    return _activityIndicatorView;
}

- (void)updateContentForPatient
{
    [self setNeedsDisplay];
}

 - (void)drawRect:(CGRect)rect
 {
     // get dimensions
     CGFloat minX = CGRectGetMaxX(self.showPatientButton.frame) + 4.0;
     CGFloat maxX = CGRectGetMinX(self.shareButton.frame) - 4.0;
     CGFloat minY = CGRectGetMaxY(self.breadcrumbLabel.frame) + self.deltaY; // account for status bar
     CGFloat maxY = CGRectGetMaxY(rect) - 4.0;
     CGFloat width = maxX - minX;
     CGFloat height = maxY - minY;
     // calculate the height of patient and wound
     CGFloat textHeight = ceilf([@"Patient Name" sizeWithAttributes:self.patientTextAttributes].height);
     textHeight += 2.0 * ceilf([@"Wound Name" sizeWithAttributes:self.woundTextAttributes].height);
     textHeight += 4.0;
     CGFloat y = minY + roundf((height - textHeight)/2.0);
     // else draw line at top
     if (self.drawTopLine) {
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextSetLineWidth(context, 0.5);
         CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
         CGContextBeginPath(context);
         CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + 19.5);
         CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + 19.5);
         CGContextStrokePath(context);
     }
     // draw patient name
     WMPatient *patient = self.patient;
     WMWound *wound = self.wound;
     NSString *string = nil;
     if (nil == patient) {
         string = @"Waiting for Patient Data";
     } else {
         string = patient.lastNameFirstName;
     }
     CGRect textRect = [string boundingRectWithSize:CGSizeMake(width, height)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:self.patientTextAttributes
                                            context:nil];
     textRect.origin.x = minX;
     textRect.origin.y = y;
     textRect.size.width = width;
     textRect = CGRectIntegral(textRect);
     [string drawInRect:textRect withAttributes:self.patientTextAttributes];
     if (nil != patient) {
         [self.activityIndicatorView stopAnimating];
     } else {
         CGRect frame = self.activityIndicatorView.frame;
         frame.origin.x = CGRectGetMinX(textRect) - 2.0 * CGRectGetWidth(frame);
         frame.origin.y = roundf(CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - CGRectGetHeight(frame))/2.0);
         self.activityIndicatorView.frame = frame;
         return;
     }
     // reduce drawing rect
     y += textRect.size.height + 4.0;
     textRect.origin.y += textRect.size.height + 4.0;
     // check for wound
     if (nil == wound) {
         NSInteger woundCount = [patient.wounds count];
         if (self.swipeEnabled) {
             string = (woundCount > 0 ? @"Swipe right to select/add wound":@"Swipe right to add wound");
         } else {
             string = @"No wounds identified";
         }
         textRect.size.height = ceilf([string sizeWithAttributes:self.noWoundTextAttributes].height);
         [string drawInRect:textRect withAttributes:self.noWoundTextAttributes];
     } else {
         // draw wound name - wound type
         string = wound.name;
         NSString *woundTypeForDisplay = [wound.woundTypeForDisplay componentsJoinedByString:@", "];
         if (0 == [string length]) {
             string = (0 == [woundTypeForDisplay length] ? @"Wound":woundTypeForDisplay);
         } else if ([woundTypeForDisplay length] > 0) {
             string = [string stringByAppendingString:[NSString stringWithFormat:@" - %@", woundTypeForDisplay]];
         }
         textRect = [string boundingRectWithSize:CGSizeMake(width, height)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:self.woundTextAttributes
                                         context:nil];
         textRect.origin.x = minX;
         textRect.origin.y = y;
         textRect.size.width = width;
         textRect = CGRectIntegral(textRect);
         [string drawInRect:textRect withAttributes:self.woundTextAttributes];
         textRect.origin.y += textRect.size.height;
         // wound location TODO finish
//         string = wound.location.title;
//         if (0 == [string length]) {
//             string = @"Unspecified Wound";
//         }
//         [string drawInRect:textRect withAttributes:self.woundTextAttributes];
     }
 }

@end

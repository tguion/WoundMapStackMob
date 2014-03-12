//
//  WMCarePlanTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 10/25/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCarePlanTableViewCell.h"
#import "WMPatient.h"
//#import "WMCarePlanGroup.h"
//#import "WMInterventionStatus.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

@interface WMCarePlanTableViewCell ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *valuesTextAttributes;
@property (strong, nonatomic) NSDictionary *statusTextAttributes;
@property (nonatomic) CGFloat valuesTextHeight;
@property (nonatomic) CGFloat statusTextHeight;

@end

@implementation WMCarePlanTableViewCell

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSDictionary *)valuesTextAttributes
{
    if (nil == _valuesTextAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        _valuesTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:12.0], NSFontAttributeName,
                                  [UIColor lightGrayColor], NSForegroundColorAttributeName,
                                  paragraphStyle, NSParagraphStyleAttributeName,
                                  nil];
    }
    return _valuesTextAttributes;
}

- (NSDictionary *)statusTextAttributes
{
    if (nil == _statusTextAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        _statusTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:12.0], NSFontAttributeName,
                                [UIColor lightGrayColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    }
    return _statusTextAttributes;
}

- (CGFloat)valuesTextHeight
{
    if (_valuesTextHeight == 0.0) {
        _valuesTextHeight = ceilf([@"Text" sizeWithAttributes:self.valuesTextAttributes].height);
    }
    return _valuesTextHeight;
}

- (CGFloat)statusTextHeight
{
    if (_statusTextHeight == 0.0) {
        _statusTextHeight = ceilf([@"Text" sizeWithAttributes:self.statusTextAttributes].height);
    }
    return _statusTextHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawContentView:(CGRect)rect
{
    WMPatient *patient = self.appDelegate.navigationCoordinator.patient;
    if (nil == patient) {
        return;
    }
    // else
//    WMCarePlanGroup *carePlanGroup = [WMCarePlanGroup mostRecentOrActiveCarePlanGroup:patient];
//    if (nil == carePlanGroup) {
//        return;
//    }
//    // else values, date modified
//    CGFloat textWidth = ceilf(CGRectGetWidth(rect)/2.0);
//    CGFloat textHeight = self.valuesTextHeight + self.statusTextHeight;
//    CGFloat x = roundf(CGRectGetMidX(rect));
//    CGFloat y = roundf((CGRectGetHeight(rect) - textHeight)/2.0);
//    NSString *entryText = ([carePlanGroup.values count] == 1 ? @"entry":@"entries");
//    NSString *string = [NSString stringWithFormat:@"%d %@ / %@", [carePlanGroup.values count], entryText, [NSDateFormatter localizedStringFromDate:carePlanGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
//    CGRect textRect = CGRectMake(x, y, textWidth, self.valuesTextHeight);
//    [string drawInRect:textRect withAttributes:self.valuesTextAttributes];
//    y += self.valuesTextHeight;
//    // status
//    string = carePlanGroup.status.title;
//    textRect = CGRectMake(x, y, textWidth, self.statusTextHeight);
//    [string drawInRect:textRect withAttributes:self.statusTextAttributes];
}

@end

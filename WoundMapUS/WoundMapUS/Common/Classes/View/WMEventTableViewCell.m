//
//  WMEventTableViewCell.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMEventTableViewCell.h"
#import "WMParticipant.h"
#import "WMInterventionEvent.h"
#import "WMInterventionEventType.h"

@implementation WMEventTableViewCell

@synthesize event=_event;

+ (NSDictionary *)boldAttributes
{
    static NSDictionary *EventTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        EventTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:13.0], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    });
    return EventTitleAttributes;
}

+ (NSDictionary *)lightAttributes
{
    static NSDictionary *EventLightAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        EventLightAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:13.0], NSFontAttributeName,
                                [UIColor grayColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    });
    return EventLightAttributes;
}

+ (NSDictionary *)normalAttributes
{
    static NSDictionary *EventDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        EventDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return EventDescAttributes;
}

- (void)setEvent:(WMInterventionEvent *)event
{
    if (_event == event) {
        return;
    }
    // else
    [self willChangeValueForKey:@"event"];
    _event = event;
    [self didChangeValueForKey:@"event"];
    if (nil != event) {
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawContentView:(CGRect)rect
{
    CGRect aFrame = UIEdgeInsetsInsetRect(rect, self.separatorInset);;
    // divide the drawing area into upper and lower slice
    CGRectEdge rectEdge = CGRectMinYEdge;
    CGFloat deltaY = CGRectGetHeight(aFrame)/2.0;
    CGRect slice1 = CGRectZero;
    CGRect slice2 = CGRectZero;
    CGRectDivide(aFrame, &slice1, &slice2, deltaY, rectEdge);
    CGFloat x = CGRectGetMinX(slice1);
    CGFloat y = CGRectGetMinY(slice1);
    CGFloat columnWidth = CGRectGetWidth(slice1)/8.0;   //divide the slide into 1/8ths
    CGFloat columnHeight = CGRectGetHeight(slice1);
    // dateEvent
    NSString *string = [NSDateFormatter localizedStringFromDate:_event.dateEvent dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    [string drawAtPoint:CGPointMake(x, y) withAttributes:[WMEventTableViewCell normalAttributes]];
    x += 3.0 * columnWidth;
    // changeType
    string = [WMInterventionEventType stringForChangeType:[_event.changeType intValue]];
    [string drawInRect:CGRectMake(x, y, 2.0 * columnWidth, columnHeight) withAttributes:[WMEventTableViewCell lightAttributes]];
    x += 2.0 * columnWidth;
    // title
    string = _event.title;
    if ([string length] == 0) {
        string = _event.eventType.title;
    }
    [string drawInRect:CGRectMake(x, y, 3.0 * columnWidth, columnHeight) withAttributes:[WMEventTableViewCell normalAttributes]];
    // move to next slice (row)
    x = CGRectGetMinX(slice2);
    y = CGRectGetMinY(slice2);
    // user.name
    string = _event.participant.name;
    [string drawInRect:CGRectMake(x, y, 2.0 * columnWidth, columnHeight) withAttributes:[WMEventTableViewCell boldAttributes]];
    x += 2.0 * columnWidth;
    // valueFrom, valueTo
    if ([_event.valueFrom length] > 0 || [_event.valueTo length] > 0) {
        string = _event.valueFrom;
        if ([string length] > 0) {
            string = [string stringByAppendingString:@" ->"];
            [string drawInRect:CGRectMake(x, y, 3.0 * columnWidth, columnHeight) withAttributes:[WMEventTableViewCell normalAttributes]];
        }
        x += 3.0 * columnWidth;
        // valueTo
        string = _event.valueTo;
        if ([string length] > 0 && ![_event.valueFrom isEqualToString:_event.valueTo]) {
            [string drawInRect:CGRectMake(x, y, 3.0 * columnWidth, columnHeight) withAttributes:[WMEventTableViewCell normalAttributes]];
        }
    } else {
        string = _event.path;
        if ([string length] > 0) {
            [string drawInRect:CGRectMake(x, y, 6.0 * columnWidth, columnHeight) withAttributes:[WMEventTableViewCell normalAttributes]];
        }
    }
}

@end

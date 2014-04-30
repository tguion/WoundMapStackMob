//
//  WMCarePlanGroupTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCarePlanGroupTableViewCell.h"
#import "WMCarePlanGroup.h"
#import "WMInterventionStatus.h"

@interface WMCarePlanGroupTableViewCell ()
@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@property (readonly, nonatomic) NSDictionary *titleAttributes;
@property (readonly, nonatomic) NSDictionary *titleSelectedAttributes;
@property (readonly, nonatomic) NSDictionary *valueAttributes;
@property (readonly, nonatomic) NSDictionary *valueSelectedAttributes;
@end

@implementation WMCarePlanGroupTableViewCell

@synthesize carePlanGroup=_carePlanGroup;
@dynamic isHighlightedOrSelected;

- (NSDictionary *)titleAttributes
{
    static NSDictionary *CarePlanTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        CarePlanTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                     [UIColor blackColor], NSForegroundColorAttributeName,
                                     paragraphStyle, NSParagraphStyleAttributeName,
                                     nil];
    });
    return CarePlanTitleAttributes;
}

- (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *CarePlanTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        CarePlanTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                             [UIColor blackColor], NSForegroundColorAttributeName,
                                             paragraphStyle, NSParagraphStyleAttributeName,
                                             nil];
    });
    return CarePlanTitleSelectedAttributes;
}

- (NSDictionary *)valueAttributes
{
    static NSDictionary *DefinitionDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return DefinitionDescAttributes;
}

- (NSDictionary *)valueSelectedAttributes
{
    static NSDictionary *DefinitionDescSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionDescSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor blackColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return DefinitionDescSelectedAttributes;
}

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

- (void)setCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
{
    if (_carePlanGroup == carePlanGroup) {
        return;
    }
    // else
    [self willChangeValueForKey:@"carePlanGroup"];
    _carePlanGroup = carePlanGroup;
    [self didChangeValueForKey:@"carePlanGroup"];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, self.separatorInset);
    // set our reference to document
    CGFloat height = CGRectGetHeight(rect);
    // draw status title
    NSString *string = self.carePlanGroup.status.title;
    if (self.carePlanGroup.isClosed) {
        string = [string stringByAppendingString:@" (closed)"];
    }
    CGSize aSize = [string sizeWithAttributes:self.titleAttributes];
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = self.titleSelectedAttributes;
    } else {
        textAttributes = self.titleAttributes;
    }
    // split rect
    CGRectEdge rectEdge = CGRectMinXEdge;
    CGFloat deltaY = CGRectGetWidth(rect)/2.0;
    CGRect slice1 = CGRectZero;
    CGRect slice2 = CGRectZero;
    CGRectDivide(rect, &slice1, &slice2, deltaY, rectEdge);
    slice1 = CGRectInset(slice1, 0.0, ceilf((height - aSize.height)/2.0));
    [string drawInRect:slice1 withAttributes:textAttributes];
    // draw date modified
    if (self.isHighlightedOrSelected) {
        textAttributes = self.valueSelectedAttributes;
    } else {
        textAttributes = self.valueAttributes;
    }
    string = [NSDateFormatter localizedStringFromDate:self.carePlanGroup.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    aSize = [string sizeWithAttributes:textAttributes];
    slice2 = CGRectInset(slice2, 0.0, ceilf((height - aSize.height)/2.0));
    [string drawInRect:slice2 withAttributes:textAttributes];
}

@end

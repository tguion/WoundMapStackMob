//
//  WCModelTextKitAtrributes.m
//  WoundMAP
//
//  Created by Todd Guion on 12/21/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WCModelTextKitAtrributes.h"

@interface WCModelTextKitAtrributes ()

@property (readonly, nonatomic) NSDictionary *headingAttributes;
@property (readonly, nonatomic) NSDictionary *subheadingAttributes;
@property (readonly, nonatomic) NSDictionary *dateAttributes;
@property (readonly, nonatomic) NSDictionary *sectionHeadingAttributes;
@property (readonly, nonatomic) NSDictionary *valueTitleAttributes;
@property (readonly, nonatomic) NSDictionary *valueAttributes;

@end

@implementation WCModelTextKitAtrributes

+ (WCModelTextKitAtrributes *)sharedInstance
{
    static WCModelTextKitAtrributes *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WCModelTextKitAtrributes alloc] init];
    });
    return SharedInstance;
}

- (NSAttributedString *)paragraphAttributedString
{
    static NSAttributedString *ParagraphAttributedString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *ParagraphAttributes = nil;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.paragraphSpacingBefore = 0.0;
        paragraphStyle.paragraphSpacing = 0.0;
        ParagraphAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor blackColor], NSForegroundColorAttributeName,
                             paragraphStyle, NSParagraphStyleAttributeName,
                             nil];
        ParagraphAttributedString = [[NSAttributedString alloc] initWithString:@"\n" attributes:ParagraphAttributes];
    });
    return ParagraphAttributedString;
}

- (NSDictionary *)headingAttributes
{
    static NSDictionary *HeadingAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.paragraphSpacingBefore = 6.0;
        HeadingAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor blackColor], NSForegroundColorAttributeName,
                             paragraphStyle, NSParagraphStyleAttributeName,
                             nil];
    });
    return HeadingAttributes;
}

- (NSMutableDictionary *)headingAttributesForFontSize:(CGFloat)fontSize
{
    NSMutableDictionary *attributes = [self.headingAttributes mutableCopy];
    [attributes setObject:[UIFont boldSystemFontOfSize:fontSize] forKey:NSFontAttributeName];
    return attributes;
}

- (NSDictionary *)subheadingAttributes
{
    static NSDictionary *SubheadingAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.paragraphSpacingBefore = 2.0;
        SubheadingAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor darkGrayColor], NSForegroundColorAttributeName,
                             paragraphStyle, NSParagraphStyleAttributeName,
                             nil];
    });
    return SubheadingAttributes;
}

- (NSMutableDictionary *)subheadingAttributesForFontSize:(CGFloat)fontSize
{
    NSMutableDictionary *attributes = [self.subheadingAttributes mutableCopy];
    [attributes setObject:[UIFont boldSystemFontOfSize:fontSize] forKey:NSFontAttributeName];
    return attributes;
}

- (NSDictionary *)dateAttributes
{
    static NSDictionary *DateAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DateAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor darkGrayColor], NSForegroundColorAttributeName,
                             paragraphStyle, NSParagraphStyleAttributeName,
                             nil];
    });
    return DateAttributes;
}

- (NSMutableDictionary *)dateAttributesForFontSize:(CGFloat)fontSize
{
    NSMutableDictionary *attributes = [self.dateAttributes mutableCopy];
    [attributes setObject:[UIFont boldSystemFontOfSize:fontSize] forKey:NSFontAttributeName];
    return attributes;
}

- (NSDictionary *)sectionHeadingAttributes
{
    static NSDictionary *SectionHeadingAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        SectionHeadingAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor lightGrayColor], NSForegroundColorAttributeName,
                                     paragraphStyle, NSParagraphStyleAttributeName,
                                     nil];
    });
    return SectionHeadingAttributes;
}

- (NSMutableDictionary *)sectionHeadingAttributesForFontSize:(CGFloat)fontSize indentLevel:(NSUInteger)indentLevel
{
    NSMutableDictionary *attributes = [self.sectionHeadingAttributes mutableCopy];
    [attributes setObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[attributes objectForKey:NSParagraphStyleAttributeName] mutableCopy];
    paragraphStyle.headIndent = Section_Indent_Value * indentLevel;
    paragraphStyle.firstLineHeadIndent = Section_Indent_Value * indentLevel;
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    return attributes;
}

- (NSDictionary *)valueTitleAttributes
{
    static NSDictionary *ValueTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        ValueTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    });
    return ValueTitleAttributes;
}

- (NSMutableDictionary *)valueTitleAttributesForFontSize:(CGFloat)fontSize indentLevel:(NSUInteger)indentLevel
{
    NSMutableDictionary *attributes = [self.valueTitleAttributes mutableCopy];
    [attributes setObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[attributes objectForKey:NSParagraphStyleAttributeName] mutableCopy];
    paragraphStyle.headIndent = Section_Indent_Value * indentLevel;
    paragraphStyle.firstLineHeadIndent = Section_Indent_Value * indentLevel;
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    return attributes;
}

- (NSDictionary *)valueAttributes
{
    static NSDictionary *ValueAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        ValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor darkGrayColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    });
    return ValueAttributes;
}

- (NSMutableDictionary *)valueAttributesForFontSize:(CGFloat)fontSize indentLevel:(NSUInteger)indentLevel
{
    NSMutableDictionary *attributes = [self.valueAttributes mutableCopy];
    [attributes setObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[attributes objectForKey:NSParagraphStyleAttributeName] mutableCopy];
    paragraphStyle.headIndent = Section_Indent_Value * indentLevel;
    paragraphStyle.firstLineHeadIndent = Section_Indent_Value * indentLevel;
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    return attributes;
}


@end

//
//  WMBradenSectionHeaderView.m
//  WoundCare
//
//  Created by Todd Guion on 8/3/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import "WMBradenSectionHeaderView.h"

@interface WMBradenSectionHeaderView()
@property (readonly, nonatomic) UILabel *titleLabel;
@property (readonly, nonatomic) UILabel *descLabel;
@end

@interface WMBradenSectionHeaderView (PrivateMethods)
+ (UIFont *)titleFont;
+ (UIFont *)normalFont;
+ (NSDictionary *)titleAttributes;
+ (NSDictionary *)descAttributes;
@end

@implementation WMBradenSectionHeaderView (PrivateMethods)

+ (UIFont *)titleFont
{
	return [UIFont boldSystemFontOfSize:15.0];
}

+ (UIFont *)normalFont
{
	return [UIFont systemFontOfSize:13.0];
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *BradenSectionHeaderTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        BradenSectionHeaderTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [WMBradenSectionHeaderView titleFont], NSFontAttributeName,
                                              [UIColor blackColor], NSForegroundColorAttributeName,
                                              paragraphStyle, NSParagraphStyleAttributeName,
                                              nil];
    });
    return BradenSectionHeaderTitleAttributes;
}

+ (NSDictionary *)descAttributes
{
    static NSDictionary *BradenSectionHeaderDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        BradenSectionHeaderDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [WMBradenSectionHeaderView normalFont], NSFontAttributeName,
                                             [UIColor blackColor], NSForegroundColorAttributeName,
                                             paragraphStyle, NSParagraphStyleAttributeName,
                                             nil];
    });
    return BradenSectionHeaderDescAttributes;
}

@end

@implementation WMBradenSectionHeaderView

- (UILabel *)titleLabel
{
	return (UILabel *)[self viewWithTag:100];
}

- (UILabel *)descLabel
{
	return (UILabel *)[self viewWithTag:200];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.tag = 100;
		titleLabel.font = [WMBradenSectionHeaderView titleFont];
		[self addSubview:titleLabel];
		UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		descLabel.tag = 200;
		descLabel.font = [WMBradenSectionHeaderView normalFont];
		descLabel.numberOfLines = 0;
		[self addSubview:descLabel];
    }
    return self;
}

- (void)updateWithBradenSection:(WMBradenSection *)bradenSection
{
	self.titleLabel.text = bradenSection.title;
	self.descLabel.text = bradenSection.desc;
}
+ (CGFloat)heightForBradenCell:(WMBradenSection *)bradenSection width:(CGFloat)width
{
	CGFloat height = 8.0;
	CGSize aSize = [bradenSection.title sizeWithAttributes:self.titleAttributes];
	height += aSize.height;
	aSize = [bradenSection.desc sizeWithAttributes:self.descAttributes];
	height += aSize.height;
	height += 4.0;
	return height;
}

- (CGSize)sizeThatFits:(CGSize)sizeToFit
{
	CGFloat width = sizeToFit.width;
	CGFloat height = 8.0;
	CGSize aSize = [self.titleLabel sizeThatFits:sizeToFit];
	height += aSize.height;
	height += 4.0;
	aSize = [self.descLabel sizeThatFits:sizeToFit];
	height += aSize.height;
	height += 4.0;
	return CGSizeMake(width, height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	[self.titleLabel sizeToFit];
	CGRect aFrame = self.titleLabel.frame;
	aFrame.origin.x = 8.0;
	aFrame.origin.y = 4.0;
	self.titleLabel.frame = aFrame;
	[self.descLabel sizeToFit];
	aFrame = self.descLabel.frame;
	aFrame.origin.x = 8.0;
	aFrame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + 8.0;
	self.descLabel.frame = aFrame;
}

@end

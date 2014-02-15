//
//  APTableViewCell.m
//  ApolloX
//
//  Created by Sharp, Andy J on 12/13/10.
//  Copyright 2010 Charles Schwab Corporation. All rights reserved.
//

#import "APTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

// TODO move this crap to proper header
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define APBlack UIColorFromRGB(0x000000)
#define APWhite UIColorFromRGB(0xFFFFFF)
#define APDarkGray UIColorFromRGB(0x333333)
#define APLightGray UIColorFromRGB(0x666666)
#define APVeryLightGray UIColorFromRGB(0xC0C0C0)
#define APVeryVeryLightGray UIColorFromRGB(0xEEEEEE)
#define APBlue UIColorFromRGB(0x005CB3)
#define APGreen UIColorFromRGB(0x009100)
#define APRed UIColorFromRGB(0xAA0033)
#define APBankGray UIColorFromRGB(0x646464)

@implementation APTableViewCellView

- (id)initWithParent:(APTableViewCell *)parent
{
	if (self = [super initWithFrame:CGRectZero]) {
		_parentCell = parent;
	}
	return self;
}

- (void)drawRect:(CGRect)r
{
	[_parentCell drawContentView:r];
}

@end

@interface APTableViewGradientCellView : APTableViewCellView
{
	
}

@end

@implementation APTableViewGradientCellView

+ (Class)layerClass {
	return [CAGradientLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		self.backgroundColor = [UIColor clearColor];
		((CAGradientLayer *)self.layer).colors = [NSArray arrayWithObjects:(id)[APVeryLightGray CGColor], (id)[APLightGray CGColor], nil];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		((CAGradientLayer *)self.layer).colors = [NSArray arrayWithObjects:(id)[APVeryLightGray CGColor], (id)[APLightGray CGColor], nil];
    }
    return self;
}

- (id)initWithParent:(APTableViewCell *)parent {
	if((self =  [super initWithFrame:CGRectZero])) {
		self.backgroundColor = [UIColor clearColor];
		((CAGradientLayer *)self.layer).colors = [NSArray arrayWithObjects:(id)[APVeryLightGray CGColor], (id)[APLightGray CGColor], nil];
		self.parentCell = parent;
	}
	return self;
}

- (void)drawRect:(CGRect)r {
	[super drawRect:r];
	[self.parentCell drawContentView:r];
}

@end

@implementation APTableViewCell

@synthesize customContentView=_customContentView;

- (void)initializeWithClass:(Class)aClass
{
    UIView *customContentView = [[aClass alloc] initWithParent:self];
    customContentView.backgroundColor = [UIColor clearColor];
    customContentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [customContentView setContentMode:UIViewContentModeRedraw];
    [self.contentView addSubview:customContentView];
    _customContentView = customContentView;
    // move all contentView subviews into customContentView
    for (UIView *aView in self.contentView.subviews) {
        if (aView == customContentView) {
            continue;
        }
        // else place into customContentView
        [aView removeFromSuperview];
        [self.customContentView addSubview:aView];
    }
    self.translatesAutoresizingMaskIntoConstraints = YES;
}

+ (Class)contentViewClass {
	return [APTableViewCellView class];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeWithClass:[APTableViewCellView class]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:style 
			   reuseIdentifier:reuseIdentifier 
						 class:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier 
			  class:(Class)contentViewClass {
	if (nil == contentViewClass) {
		contentViewClass = [[self class] contentViewClass];
	}
    self =  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(nil != self) {
		UIView *customContentView = [[contentViewClass alloc] initWithParent:self];
		customContentView.backgroundColor = [UIColor clearColor];
        customContentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [customContentView setContentMode: UIViewContentModeRedraw];
		[self.contentView addSubview:customContentView];
        _customContentView = customContentView;
        self.translatesAutoresizingMaskIntoConstraints = YES;
    }
    return self;
}

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	
    [super setSelected:selected animated:animated];
	// Configure the view for the selected state
	[_customContentView setNeedsDisplay];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[_customContentView setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _customContentView.frame = self.contentView.bounds;
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[_customContentView setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
	// subclasses should implement this
}

@end

@implementation APTableViewGradientCell

+ (Class)contentViewClass {
	return [APTableViewGradientCellView class];
}


@end
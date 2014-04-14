//
//  WMNavigationNodeButton.m
//  WoundPUMP
//
//  Created by Todd Guion on 7/19/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMNavigationNodeButton.h"
#import "WMNavigationNode.h"
#import "WMPolicyManager.h"
#import "WMDesignUtilities.h"
#import "WCAppDelegate.h"

@interface WMNavigationNodeButton ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) BOOL isIPadIdiom;
@property (readonly, nonatomic) WMPolicyManager *policyManager;
@property (readonly, nonatomic) CGFloat standardWidth;
@property (readonly, nonatomic) CGFloat standardHeight;
@property (weak, nonatomic) UIImageView *iconImageView;
@property (weak, nonatomic) UILabel *nodeTitleLabel;
@property (readonly, nonatomic) UIFont *titleFont;
@property (weak, nonatomic) UIImageView *statusImageView;
@property (readonly, nonatomic) NSDictionary *titleAttributes;
@property (readonly, nonatomic) NSDictionary *titleSelectedAttributes;
@property (readonly, nonatomic) NSString *iconImageName;
@property (readonly, nonatomic) NSArray *iCloudIconImages;
@end

@implementation WMNavigationNodeButton

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)isIPadIdiom
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (WMPolicyManager *)policyManager
{
    return [WMPolicyManager sharedInstance];
}

- (void)initialize
{
    // configure node title label
    self.nodeTitleLabel.font = self.titleFont;
    self.nodeTitleLabel.numberOfLines = 0;
    self.nodeTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nodeTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.nodeTitleLabel.textColor = UIColorFromRGB(0x919CA6);
    _complianceDelta = NSNotFound;
    self.showsTouchWhenHighlighted = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithNavigationNode:(WMNavigationNode *)navigationNode rotationDirection:(MapBaseRotationDirection)rotationDirection
{
    self = [self initWithFrame:CGRectMake(0.0, 0.0, self.standardWidth, self.standardHeight)];
    if (self) {
        self.rotationDirection = rotationDirection;
        self.navigationNode = navigationNode;
    }
    return self;
}

- (CGFloat)standardWidth
{
    return (self.isIPadIdiom ? 120.0:72.0);
}

- (CGFloat)standardHeight
{
    return (self.isIPadIdiom ? 80.0:63.0);
}

- (UIImageView *)iconImageView
{
    if (nil == _iconImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        _iconImageView = imageView;
    }
    return _iconImageView;
}

- (UIImageView *)statusImageView
{
    if (self.navigationNode.hidesStatusIndicator) {
        return nil;
    }
    // else
    if (nil == _statusImageView) {
        // insert status imageView
        NSString *imageName = (self.isIPadIdiom ? @"alert_green_iPad":@"alert_green_iPhone");
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:imageView];
        imageView.frame = CGRectMake(4.0, 4.0, image.size.width, image.size.height);
        _statusImageView = imageView;
    }
    return _statusImageView;
}

- (UILabel *)nodeTitleLabel
{
    if (nil == _nodeTitleLabel) {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        _nodeTitleLabel = label;
    }
    return _nodeTitleLabel;
}

- (NSDictionary *)titleAttributes
{
    static NSDictionary *NavigationNodeButtonTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NavigationNodeButtonTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [self titleFont], NSFontAttributeName,
                                   [UIColor blackColor], NSForegroundColorAttributeName,
                                   paragraphStyle, NSParagraphStyleAttributeName,
                                   nil];
    });
    return NavigationNodeButtonTitleAttributes;
}

- (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *NavigationNodeButtonTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NavigationNodeButtonTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [self titleFont], NSFontAttributeName,
                                               [UIColor whiteColor], NSForegroundColorAttributeName,
                                               paragraphStyle, NSParagraphStyleAttributeName,
                                               nil];
    });
    return NavigationNodeButtonTitleSelectedAttributes;
}

+ (UIFont *)titleFont
{
    static UIFont *TitleFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL isIPadIdiom = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        TitleFont = [UIFont systemFontOfSize:(isIPadIdiom ? 15.0:11.0)];
    });
    return TitleFont;
}

- (UIFont *)titleFont
{
    return [WMNavigationNodeButton titleFont];
}

- (void)setNavigationNode:(WMNavigationNode *)navigationNode
{
    if (_navigationNode == navigationNode) {
        return;
    }
    // else
    [self willChangeValueForKey:@"navigationNode"];
    _navigationNode = navigationNode;
    [self didChangeValueForKey:@"navigationNode"];
    [self updateUIFromNavigationNode];
    [self setNeedsLayout];
}

- (NSString *)iconImageName
{
    NSString *iconSuffix = (self.isIPadIdiom ? @"_iPad":@"_iPhone");
    NSString *disabledFragment = (self.isEnabled ? @"":@"_Disabled");
    return [[self.navigationNode.icon stringByAppendingString:disabledFragment] stringByAppendingString:iconSuffix];
}

- (NSArray *)iCloudIconImages
{
    NSString *iconSuffix = (self.isIPadIdiom ? @"_iPad":@"_iPhone");
    return @[[UIImage imageNamed:[NSString stringWithFormat:@"iCloud_download%@_A", iconSuffix]], [UIImage imageNamed:[NSString stringWithFormat:@"iCloud_download%@_B", iconSuffix]]];
}

- (void)updateUIFromNavigationNode
{
    NSString *iconImageName = self.iconImageName;
    UIImage *icon = [UIImage imageNamed:iconImageName];
    if (nil == icon) {
        icon = [UIImage animatedImageWithImages:self.iCloudIconImages duration:1.0];
    } else {
        self.iconImageView.image = icon;
    }
    self.nodeTitleLabel.text = self.navigationNode.displayTitle;
    if (self.navigationNode.hidesStatusIndicator) {
        _statusImageView.hidden = YES;
    } else {
        _statusImageView.hidden = NO;
    }
}

- (void)setComplianceDelta:(NSInteger)complianceDelta
{
    if (_complianceDelta == complianceDelta) {
        return;
    }
    // else
    [self willChangeValueForKey:@"complianceDelta"];
    _complianceDelta = complianceDelta;
    [self didChangeValueForKey:@"complianceDelta"];
    self.statusImageView.image = [self.policyManager statusImageForComplianceDelta:complianceDelta];
}

#pragma mark - UIView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (nil == newSuperview) {
        [self.policyManager unregisterNavigationNodeButton:self];
    } else {
        [self.policyManager registerNavigationNodeButton:self];
    }
}

- (void)layoutSubviews
{
    // do not call super
    if (nil == _navigationNode) {
        return;
    }
    // else
    [self centerImageViewAndLabel];
}

// http://stackoverflow.com/questions/2451223/uibutton-how-to-center-an-image-and-a-text-using-imageedgeinsets-and-titleedgei
- (void)centerImageViewAndLabel
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    // the space between the image and text
    CGFloat spacing = 2.0;
    CGFloat textMargin = 4.0;
    CGRect textRect = [self.navigationNode.displayTitle boundingRectWithSize:CGSizeMake(width - 2.0 * textMargin, 10000.0)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                  attributes:self.titleAttributes
                                                                     context:nil];

    
    // get the size of the elements here for readability
    NSString *iconSuffix = (self.isIPadIdiom ? @"_iPad":@"_iPhone");
    NSString *fileName = [self.navigationNode.icon stringByAppendingString:iconSuffix];
    UIImage *icon = [UIImage imageNamed:fileName];
    if (nil == icon) {
        // might be issue with case
        fileName = [[[fileName substringToIndex:1] uppercaseString] stringByAppendingString:[fileName substringFromIndex:1]];
        icon = [UIImage imageNamed:fileName];
    }
//    NSAssert1(nil != icon, @"Unable to resolve navigation icon for file name %@", fileName);
    CGSize imageSize = icon.size;
    CGFloat totalHeight = ceilf(imageSize.height + textRect.size.height + spacing);      // get the height they will take up as a unit
    
    // set the imageView frame
    CGRect frame = CGRectMake(roundf((width - imageSize.width)/2.0), fmaxf(2.0, roundf((height - totalHeight)/2.0)), imageSize.width, imageSize.height);
    self.iconImageView.frame = frame;
    // set the label frame
    frame = CGRectMake(textMargin, CGRectGetMaxY(self.iconImageView.frame) + spacing, width - 2.0 * textMargin, ceilf(textRect.size.height));
    self.nodeTitleLabel.frame = frame;
    // position the status image view only if enabled
    if (self.isEnabled && !self.navigationNode.hidesStatusIndicator) {
        frame = self.statusImageView.frame;
        frame.origin.x = CGRectGetMaxX(self.iconImageView.frame) - 4.0;
        frame.origin.y = CGRectGetMaxY(self.iconImageView.frame) - CGRectGetHeight(frame)/2.0;
        // make sure it doesn't overlap label
        CGRect rect = CGRectIntersection(self.nodeTitleLabel.frame, frame);
        frame.origin.y -= CGRectGetHeight(rect);
        self.statusImageView.frame = frame;
    }
}

#pragma mark - UIButton

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    NSString *iconImageName = self.iconImageName;
    UIImage *icon = [UIImage imageNamed:iconImageName];
    if (icon) {
        self.iconImageView.image = icon;
    }
    if (enabled) {
        [self setNeedsLayout];
    } else {
        [_statusImageView removeFromSuperview];
    }
}

@end

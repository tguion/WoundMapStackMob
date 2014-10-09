//
//  WMHairlineView.m
//

#import "WMHairlineView.h"

#define HAIRLINE_COLOR 204.0/255.0

@interface WMHairlineView ()
@property (nonatomic) WMHairlineAlignment alignment;
@end

@implementation WMHairlineView

+ (WMHairlineView *)hairlineViewForAlignment:(WMHairlineAlignment)alignment
{
    WMHairlineView *view = [[self alloc] initWithFrame:CGRectZero];
    view.alignment = alignment;
    return view;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    self.backgroundColor = [UIColor colorWithWhite:HAIRLINE_COLOR alpha:1];
    self.alignment = WMHairlineAlignmentHorizontal;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self)
        return nil;
    self.backgroundColor = [UIColor colorWithWhite:HAIRLINE_COLOR alpha:1];
    self.alignment = WMHairlineAlignmentHorizontal;
    return self;
}

- (CGFloat)thickness
{
    return [[UIScreen mainScreen] scale] > 1 ? 0.5 : 1.0;
}

- (void)setFrame:(CGRect)frame
{
    CGFloat hairline = self.thickness;
    if (CGRectGetWidth(frame) > CGRectGetHeight(frame)) {
        frame.size.height = hairline;
        _alignment = WMHairlineAlignmentHorizontal;
        [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    else {
        frame.size.width = hairline;
        _alignment = WMHairlineAlignmentHorizontal;
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    }
    [super setFrame:frame];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat hairline = self.thickness;
    if (size.width > size.height)
        size.height = hairline;
    else
        size.width = hairline;
    return size;
}

- (CGSize)intrinsicContentSize
{
    if (WMHairlineAlignmentHorizontal == _alignment)
        return CGSizeMake(UIViewNoIntrinsicMetric, self.thickness);
    else
        return CGSizeMake(self.thickness, UIViewNoIntrinsicMetric);
}
@end

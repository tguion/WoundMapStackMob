//
//  WMDisclosureImageView.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMDisclosureImageView.h"
#import "WMDesignUtilities.h"

@interface WMDisclosureImageView ()
@property (readonly, nonatomic) UIImage *imageForSelectionCount;
@end

@interface WMDisclosureImageView (PrivateMethods)
- (void)addDisclosureLayer;
- (UIImage *)imageForSelectionCount:(NSInteger)selectionCount;
- (void)updateForSelectionCount;
@end

@implementation WMDisclosureImageView (PrivateMethods)

- (void)addDisclosureLayer
{
    disclosureLayer = [CALayer layer];
    UIImage *image = [UIImage imageNamed:@"ui_btnarrow"];
    disclosureLayer.contents = (__bridge id)(image.CGImage);
    disclosureLayer.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
	disclosureLayer.anchorPoint = CGPointMake(0.5, 0.5);
    disclosureLayer.hidden = YES;
    disclosureLayer.opacity = 0.75;
    [self.layer insertSublayer:disclosureLayer above:self.layer];
}

- (UIImage *)imageForSelectionCount:(NSInteger)selectionCount
{
    UIImage *image = nil;
    switch (selectionCount) {
        case NSNotFound: {
            // nil
            break;
        }
        case 0: {
            image = [WMDesignUtilities unselectedWoundTableCellImage];
            break;
        }
        case 1: {
            image = [WMDesignUtilities selectedWoundTableCellImage];
            break;
        }
        default: {
            selectionCount = MIN(selectionCount, 10);
            image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_%ld", (long)selectionCount]];
            break;
        }
    }
    return image;
}

- (void)updateForSelectionCount
{
    self.image = self.imageForSelectionCount;
    if (NSNotFound == self.selectionCount || 0 == self.selectionCount || 1 == self.selectionCount) {
        disclosureLayer.hidden = YES;
        self.userInteractionEnabled = NO;
    } else {
        disclosureLayer.hidden = NO;
        self.userInteractionEnabled = YES;
    }
}

@end

@implementation WMDisclosureImageView

@synthesize selectionCount=_selectionCount, openFlag=_openFlag;
@dynamic imageForSelectionCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addDisclosureLayer];
        [self updateForSelectionCount];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGRect aRect = CGRectInset(self.bounds, (width - 44.0)/2.0, (height - 44.0)/2.0);
    return CGRectContainsPoint(aRect, point);
}

- (void)setSelectionCount:(NSInteger)selectionCount
{
    if (_selectionCount == selectionCount) {
        return;
    }
    // else
    [self willChangeValueForKey:@"selectionCount"];
    _selectionCount = selectionCount;
    [self didChangeValueForKey:@"selectionCount"];
    [self updateForSelectionCount];
}

- (void)setOpenFlag:(BOOL)openFlag
{
    if (_openFlag == openFlag) {
        return;
    }
    // else
    [self willChangeValueForKey:@"openFlag"];
    _openFlag = openFlag;
    [self didChangeValueForKey:@"openFlag"];
    if (openFlag) {
        self.layer.sublayerTransform = CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0);
    } else {
        self.layer.sublayerTransform = CATransform3DIdentity;
    }
}

- (UIImage *)imageForSelectionCount
{
    return [self imageForSelectionCount:self.selectionCount];
}

@end

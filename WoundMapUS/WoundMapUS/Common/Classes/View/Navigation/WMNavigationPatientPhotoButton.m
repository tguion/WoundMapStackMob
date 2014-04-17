//
//  WMNavigationPatientPhotoButton.m
//  WoundPUMP
//
//  Created by Todd Guion on 9/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMNavigationPatientPhotoButton.h"
#import "WMPatient.h"
#import "WMPhotoManager.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

#define kNavigationImageInset 16.0

@interface WMNavigationPatientPhotoButton ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) BOOL isIPadIdiom;
@property (readonly, nonatomic) WMPhotoManager *photoManager;
@property (readonly, nonatomic) WMPatient *patient;
@property (nonatomic) CGFloat overlayAlpha;
@property (strong, nonatomic) NSDictionary *navigationNodeTitleAttributes;

@end

@implementation WMNavigationPatientPhotoButton

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)isIPadIdiom
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (WMPhotoManager *)photoManager
{
    return [WMPhotoManager sharedInstance];
}

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (NSDictionary *)navigationNodeTitleAttributes
{
    if (nil == _navigationNodeTitleAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        _navigationNodeTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                          [UIColor colorWithWhite:0.1 alpha:0.8], NSForegroundColorAttributeName,
                                          paragraphStyle, NSParagraphStyleAttributeName,
                                          nil];
    }
    return _navigationNodeTitleAttributes;
}

- (void)setActionState:(CompassViewActionState)actionState
{
    if (_actionState == actionState) {
        return;
    }
    // else
    [self willChangeValueForKey:@"actionState"];
    _actionState = actionState;
    [self didChangeValueForKey:@"actionState"];
    [self setNeedsDisplay];
}

- (void)setNavigationNodeTitle:(NSString *)navigationNodeTitle
{
    if ([_navigationNodeTitle isEqualToString:navigationNodeTitle]) {
        return;
    }
    // else
    [self willChangeValueForKey:@"navigationNodeTitle"];
    _navigationNodeTitle = navigationNodeTitle;
    [self didChangeValueForKey:@"navigationNodeTitle"];
    [self setNeedsDisplay];
}

- (void)updateForPatient:(WMPatient *)patient
{
    self.overlayAlpha = (nil == patient.thumbnail ? 1.0:0.05);
    [self setNeedsDisplay];
}
                                                 
- (CGRect)imageRect
{
     return CGRectInset(self.bounds, kNavigationImageInset, kNavigationImageInset);
}

- (CGRect)navigationImageFrameForImageName:(NSString *)imageName title:(NSString *)title inView:(UIView *)view
{
    CGRect rect = self.bounds;
    CGRect imageRect = CGRectInset(rect, kNavigationImageInset, kNavigationImageInset);
    CGSize aSize = [title sizeWithAttributes:self.navigationNodeTitleAttributes];
    UIImage *icon = [UIImage imageNamed:imageName];
    CGFloat x = CGRectGetMinX(imageRect) + roundf((CGRectGetWidth(imageRect) - icon.size.width)/2.0);
    CGFloat totalHeight = ceilf(icon.size.height + 4.0 + aSize.height);
    CGFloat y = CGRectGetMinY(imageRect) + roundf((CGRectGetHeight(imageRect) - totalHeight)/2.0);
    CGRect frame = CGRectMake(x, y, icon.size.width, icon.size.height);
    if (nil != view) {
        frame = [view convertRect:frame fromView:self];
    }
    return frame;
}

- (void)drawRect:(CGRect)rect
{
    // draw patient in center
    CGRect imageRect = self.imageRect;
    // draw action state
    NSString *imageName = nil;
    CGFloat overlayAlpha = self.overlayAlpha;
    switch (self.actionState) {
        case CompassViewActionStateNone: {
            // nothing
            break;
        }
        case CompassViewActionStateHome: {
            // show camera
            imageName = (self.isIPadIdiom ? @"camera_iPad":@"camera_iPhone");
            break;
        }
        case CompassViewActionStateLevel1: {
            // one step from home
            imageName = (self.isIPadIdiom ? @"home_iPad":@"home_iPhone");
            overlayAlpha = 1.0;
            break;
        }
        case CompassViewActionStateLevel2:
        case CompassViewActionStateLevel3: {
            // more than one step from home
            imageName = (self.isIPadIdiom ? @"homeback_iPad":@"homeback_iPhone");
            overlayAlpha = 1.0;
            break;
        }
    }
    if ([imageName length] > 0) {
        UIImage *image = [UIImage imageNamed:imageName];
        CGFloat width = CGRectGetWidth(rect);
        CGFloat height = CGRectGetHeight(rect);
        CGFloat x = roundf((width - image.size.width)/2.0);
        CGFloat y = roundf((height - image.size.height)/2.0);
        [image drawAtPoint:CGPointMake(x, y) blendMode:kCGBlendModeLighten alpha:overlayAlpha];
    }
    if ([self.navigationNodeTitle length] > 0) {
        CGFloat width = CGRectGetWidth(imageRect) - 8.0;
        CGRect iconRect = [self navigationImageFrameForImageName:self.navigationNodeIconName title:self.navigationNodeTitle inView:nil];
        UIImage *icon = [UIImage imageNamed:self.navigationNodeIconName];
        CGFloat x = iconRect.origin.x;
        CGFloat y = iconRect.origin.y;
        [icon drawAtPoint:CGPointMake(x, y) blendMode:kCGBlendModeNormal alpha:0.8];
        x = CGRectGetMinX(imageRect) + 4.0;
        y += icon.size.height + 4.0;
        [self.navigationNodeTitle drawInRect:CGRectMake(x, y, width, ceilf([self.navigationNodeTitle sizeWithAttributes:self.navigationNodeTitleAttributes].height)) withAttributes:self.navigationNodeTitleAttributes];
    }
}

@end

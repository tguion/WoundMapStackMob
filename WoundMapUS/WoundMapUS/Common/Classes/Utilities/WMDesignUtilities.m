//
//  WMDesignUtilities.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/4/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMDesignUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation WMDesignUtilities

+ (void)updateAppearanceForEssential
{
    UIColor *tintColor = [self tintColorForEssential];
    [[UINavigationBar appearance] setTintColor:tintColor];
    [[UIToolbar appearance] setTintColor:tintColor];
    [[UINavigationBar appearance] setBarTintColor:tintColor];
    [[UIToolbar appearance] setBarTintColor:tintColor];
}

+ (void)updateAppearanceForPUMP
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // white content
    UIColor *tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTintColor:tintColor];
    [[UIToolbar appearance] setTintColor:tintColor];
    // tint background
    tintColor = [self tintColorForPUMP];
    [[UINavigationBar appearance] setBarTintColor:tintColor];
    [[UIToolbar appearance] setBarTintColor:tintColor];
    // title
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Helvetica Neue" size:17], NSFontAttributeName,
                                UIColorFromRGB(0x1D9280), NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
}

+ (UIColor *)tintColorForEssential
{
    return UIColorFromRGB(0x18889C);
}

+ (UIColor *)tintColorForPUMP
{
    static UIColor *TintColorForPUMP = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TintColorForPUMP = UIColorFromRGB(0x29D1B7);
    });
    return TintColorForPUMP;
}

+ (UIColor *)tintColorForBarInPopoverPUMP
{
    static UIColor *TintColorForBarInPopoverPUMP = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TintColorForBarInPopoverPUMP = UIColorFromRGB(0x00B287);
    });
    return TintColorForBarInPopoverPUMP;
}

+ (UIColor *)tintColorTranslucentForPUMP
{
    static UIColor *TintColorTranslucentForPUMP = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TintColorTranslucentForPUMP = [UIColor colorWithRed:(CGFloat)0x29/(CGFloat)0xFF green:(CGFloat)0xD1/(CGFloat)0xFF blue:(CGFloat)0xB7/(CGFloat)0xFF alpha:0.1];
    });
    return TintColorTranslucentForPUMP;
}

// color of border for photo grid view
+ (UIColor *)gridImageViewContainerBorderColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)semiTransparentDateLabelBackgroundColor
{
    return [UIColor colorWithWhite:0.95 alpha:0.5];
}

+ (UIColor *)semiTransparentMeasurementLabelBackgroundColor
{
    return [UIColor colorWithWhite:0.5 alpha:0.5];
}

+ (UIImage *)unselectedWoundTableCellImage
{
    return [UIImage imageNamed:@"ui_circle.png"];
}

+ (UIImage *)selectedWoundTableCellImage
{
    return [UIImage imageNamed:@"ui_checkmark.png"];
}

+ (void)applyDrowShadowToTableCellImageView:(UIImageView *)imageView
{
    imageView.layer.shadowRadius = 2.0;
    imageView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    imageView.layer.shadowOpacity = 0.6;
}

#pragma mark - PDF

+ (UIColor *)pdfPatientHeaderBackgroundColor
{
    return [UIColor colorWithRed:0.3 green:0.7 blue:0.2 alpha:1.0];
}

@end

@implementation UIColor (UITableViewBackground)

+ (UIColor *)groupTableViewBackgroundColor
{
    return [UIColor colorWithWhite:0.92 alpha:1.0];
}

@end

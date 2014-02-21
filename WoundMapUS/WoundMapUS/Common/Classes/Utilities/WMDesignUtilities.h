//
//  WMDesignUtilities.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/4/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface WMDesignUtilities : NSObject

// IAP Product colors
+ (void)updateAppearanceForEssential;
+ (void)updateAppearanceForPUMP;

+ (UIColor *)tintColorForEssential;
+ (UIColor *)tintColorForPUMP;
+ (UIColor *)tintColorForBarInPopoverPUMP;
+ (UIColor *)tintColorTranslucentForPUMP;

+ (UIColor *)gridImageViewContainerBorderColor;
+ (UIColor *)semiTransparentDateLabelBackgroundColor;
+ (UIColor *)semiTransparentMeasurementLabelBackgroundColor;

+ (UIImage *)unselectedWoundTableCellImage;
+ (UIImage *)selectedWoundTableCellImage;

+ (void)applyDrowShadowToTableCellImageView:(UIImageView *)imageView;

#pragma mark - PDF
+ (UIColor *)pdfPatientHeaderBackgroundColor;

@end

@interface UIColor (UITableViewBackground)
+ (UIColor *)groupTableViewBackgroundColor;
@end

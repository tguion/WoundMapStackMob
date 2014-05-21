//
//  WMNutritionGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBuildGroupViewController.h"

@class WMNutritionGroupViewController;
@class WMNutritionGroup;

@protocol NutritionGroupViewControllerDelegate <NSObject>

- (void)nutritionGroupViewControllerDidSave:(WMNutritionGroupViewController *)viewController;
- (void)nutritionGroupViewControllerDidCancel:(WMNutritionGroupViewController *)viewController;

@end

@interface WMNutritionGroupViewController : WMBuildGroupViewController

@property (weak, nonatomic) id<NutritionGroupViewControllerDelegate> delegate;

@end

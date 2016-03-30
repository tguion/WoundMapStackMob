//
//  WMNutritionSummaryViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/22/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMNutritionGroup;

@interface WMNutritionSummaryViewController : UIViewController

@property (strong, nonatomic) WMNutritionGroup *nutritionGroup;
@property (nonatomic) BOOL drawFullHistory;

@end

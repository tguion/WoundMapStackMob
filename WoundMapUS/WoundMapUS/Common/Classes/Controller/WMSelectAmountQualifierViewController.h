//
//  WMSelectAmountQualifierViewController.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/25/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMSelectAmountQualifierViewController, WCAmountQualifier;

@protocol SelectAmountQualifierViewControllerDelegate <NSObject>

@property (strong, nonatomic) WCAmountQualifier *selectedAmountQualifier;

- (void)selectAmountQualifierViewController:(WMSelectAmountQualifierViewController *)viewController didSelectQualifierAmount:(WCAmountQualifier *)amount;
- (void)selectAmountQualifierViewControllerDidCancel:(WMSelectAmountQualifierViewController *)viewController;

@end

@interface WMSelectAmountQualifierViewController : WMBaseViewController

@property (weak, nonatomic) id<SelectAmountQualifierViewControllerDelegate> delegate;
@property (strong, nonatomic) WCAmountQualifier *amountQualifier;

@end

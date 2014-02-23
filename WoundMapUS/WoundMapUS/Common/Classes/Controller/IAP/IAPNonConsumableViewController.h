//
//  IAPPurchaseViewController.h
//  WoundPUMP
//
//  Created by John Scarpaci on 7/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//
//  IAP: redo using UITableView, where the content is loaded by a plist
//  The description needs to be html, one element in the plist. Use UIWebView
//  Figure out how to determine the size of each UITableViewCell
//  Put the purchase button in self.tableView.tableFooterView

#import <UIKit/UIKit.h>
#import "IAPBaseViewController.h"
#import "IAPManager.h"

@class IAPNonConsumableViewController;

@protocol IAPNonConsumableViewControllerDelegate <NSObject>

- (void)iapNonConsumableViewControllerDidCancel:(IAPNonConsumableViewController *)controller;
- (void)iapNonConsumableViewControllerDidPurchaseFeature:(IAPNonConsumableViewController *)controller;

@end


@interface IAPNonConsumableViewController : IAPBaseViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) id<IAPNonConsumableViewControllerDelegate> delegate;

@end

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

@interface IAPNonConsumableViewController : IAPBaseViewController

@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;
@property (strong, nonatomic) IBOutlet UIButton *purchaseButtonDescView;

@end

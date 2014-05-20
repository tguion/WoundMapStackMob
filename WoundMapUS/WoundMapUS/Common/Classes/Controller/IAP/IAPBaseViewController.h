//
//  IAPBaseViewController.h
//  WoundPUMP
//
//  Created by Todd Guion on 11/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//
//  IAP: this is the base class for view controllers that will be presented when the user selects
//  content that is included in an IAP and has not purchased that IAP

#import "WMBaseViewController.h"

enum {
    kIAPProductTitleRow = 0,
    kIAPProductDescriptionRow = 1,
    kIAPProductPropositionRow = 2,
    kIAPProductFeaturesRow = 3,
    kIAPProductPriceRow = 4
};

extern CGFloat const kIAPTextVerticalMargin;

@class IAPProduct;
@class IAPBaseViewController;

@interface IAPBaseViewController : WMBaseViewController

@property (strong, nonatomic) IAPProduct *iapProduct;
@property (strong, nonatomic) SKProduct *skProduct;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) NSDictionary *textAttributes;
@property (strong, nonatomic) IAPPresentViewControllerAcceptHandler acceptHandler;
@property (strong, nonatomic) IAPPresentViewControllerDeclineHandler declineHandler;

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath;

- (IBAction)cancelAction:(id)sender;
- (IBAction)purchaseAction:(id)sender;

- (void)iapFailureAlert:(NSString*)message;
- (void)reloadData;
- (void)skProductforProductId:(NSString *)productId;

- (void)setSelectedIapProduct:(IAPProduct *)selectedIapProduct;
- (void)setSelectedSkProduct:(SKProduct *)selectedSkProduct;


@end

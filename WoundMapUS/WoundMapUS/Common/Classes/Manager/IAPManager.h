//
//  IAPManager.h
//  WoundPUMP
//
//  Created by John Scarpaci on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "WCIAPTransaction+Custom.h"

@class IAPProduct;

typedef void (^IAPSuccessHandler)(NSArray* products);
typedef void (^IAPFailureHandler)(NSError* error);

extern NSString *const kIAPManagerProductPurchasedNotification;
extern NSString *const kIAPPurchaseError;
extern NSString *const kIAPTxnCancelled;
extern NSString *const kIAPDeviceTransactionAggregate;

@interface IAPManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (readonly, nonatomic) BOOL hasSharePdfReportsAvailable;
@property (readonly, nonatomic) NSDate *lastCreditPurchaseDate;
@property (readonly, nonatomic) NSInteger pdfTokensAvailable;

+ (IAPManager *)sharedInstance;

- (BOOL)isProductPurchased:(IAPProduct *)iapProduct;
- (void)buyProduct:(SKProduct *)product;

- (void)productWithProductId:(NSString*)productId successHandler:(IAPSuccessHandler)successHandler
              failureHandler:(IAPFailureHandler)failureHandler;
- (void)productsWithProductIdSet:(NSSet*)productIdSet successHandler:(IAPSuccessHandler)successHandler failureHandler:(IAPFailureHandler)failureHandler;

- (void)sharePdfReportCreditHasBeenUsed;

- (WCIAPTransaction *) addCreditTransaction:(NSNumber *)credits;

- (void) resetTokenCount;
- (void) diagDumpAction;

@end

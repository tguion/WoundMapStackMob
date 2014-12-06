//
//  IAPManager.h
//  WoundPUMP
//
//  Created by John Scarpaci on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "WMIAPTransaction.h"

@class IAPProduct;

typedef void (^IAPSuccessHandler)(NSArray *products);
typedef void (^IAPFailureHandler)(NSError *error);
typedef void (^IAPTokenCountHandler)(NSError *error, NSInteger tokenCount, NSDate *lastTokenCreditPurchaseDate);

extern NSString *const kSharePdfReport5Feature;
extern NSString *const kSharePdfReport10Feature;
extern NSString *const kSharePdfReport25Feature;

extern NSString *const kTeamMemberProductIdentifier;
extern NSString *const kCreateConsultingGroupProductIdentifier;

extern NSString *const kIAPManagerProductPurchasedNotification;
extern NSString *const kIAPPurchaseError;
extern NSString *const kIAPTxnCancelled;
extern NSString *const kIAPDeviceTransactionAggregate;

@interface IAPManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (IAPManager *)sharedInstance;

- (void)processPendingTransactions;

- (NSString *)updatePriceInString:(NSString *)string skProducts:(NSArray *)products;

- (NSString *)getIAPDeviceGuid;

- (void)pdfTokensAvailable:(IAPTokenCountHandler)completionHandler;

- (BOOL)isProductPurchased:(IAPProduct *)iapProduct;
- (void)buyProduct:(SKProduct *)product;
- (void)buyProduct:(SKProduct *)product quantity:(NSInteger)quantity;

- (void)productWithProductId:(NSString *)productId
              successHandler:(IAPSuccessHandler)successHandler
              failureHandler:(IAPFailureHandler)failureHandler;
- (void)productsWithProductIdSet:(NSSet *)productIdSet
                  successHandler:(IAPSuccessHandler)successHandler
                  failureHandler:(IAPFailureHandler)failureHandler;

- (void)sharePdfReportCreditHasBeenUsed;

- (WMIAPTransaction *)addCreditTransaction:(NSNumber *)credits;

- (void)resetTokenCount;
- (void)diagDumpAction;

@end

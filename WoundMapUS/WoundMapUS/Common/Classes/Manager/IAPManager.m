//
//  IAPManager.m
//  WoundPUMP
//
//  Created by John Scarpaci on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//
//  IAP: initiate a call to Store Kit to get all registered products, and update our IAPProduct model using LocalStoreManager managedObjectContext and persistentStore
//  This seeding needs to occur as soon as the local store has been initialized

#import "IAPManager.h"
#import "DocumentManager.h"
#import "IAPProduct+Custom.h"
#import "IAPDeviceTransactionAggregate.h"
#import "IAPCreditTransaction.h"
#import "WCIAPTransaction+Custom.h"
#import "WCUtilities.h"
#import "WCAppDelegate.h"
#import "CoreDataController.h"

NSString *const kSharePdfReport5Feature = @"com.mobilehealthware.woundcare.woundmap.cad.print5.token";
NSString *const kSharePdfReport10Feature = @"com.mobilehealthware.woundcare.woundmap.cad.print10.token";
NSString *const kSharePdfReport25Feature = @"com.mobilehealthware.woundcare.woundmap.cad.print25.token";

NSString *const kIAPManagerProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const kIAPPurchaseError = @"IAPPurchaseError";
NSString *const kIAPTxnCancelled = @"IAPTxnCancelled";

NSString *const kIAPDeviceTransactionAggregate = @"IAPDeviceTransactionAggregate";
int kStartupCreditAmount = 10000;

NSString *const kIAPDeviceId = @"iap-device-id.txt";

@interface IAPManager ()

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;

@end

@implementation IAPManager

SKProductsRequest * _productsRequest;

IAPSuccessHandler _successHandler;
IAPFailureHandler _failureHandler;

NSString* _deviceId;

#pragma mark - Initialization

+ (IAPManager *)sharedInstance
{
    static IAPManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[IAPManager alloc] init];
        __weak __typeof(SharedInstance) weakSelf = SharedInstance;
        [[NSNotificationCenter defaultCenter] addObserverForName:kLocalStoresLoadedNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [weakSelf updateAggregateTotalForDevice];
                                                      }];

        [[NSNotificationCenter defaultCenter] addObserverForName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [weakSelf handleExternalChangeNotification:notification];
                                                      }];
        
    });
    return SharedInstance;
}

- (NSManagedObjectContext *)managedObjectContext
{
    WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.coreDataController.mainThreadContext;
}

- (NSPersistentStore *)store
{
    WCAppDelegate *appDelegate = (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.coreDataController.iCloudStoreOrFallbackStore;
}

- (id)init {

    if ((self = [super init])) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    DLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        DLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _successHandler(skProducts);
    _successHandler = nil;
    _failureHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    DLog(@"Failed to load list of products. - error.description is - %@", error.description);
    _failureHandler(error);
    _failureHandler = nil;
    _successHandler = nil;
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (BOOL)isProductPurchased:(IAPProduct *)iapProduct
{
    BOOL result = NO;
    if (iapProduct.aggregatorFlag) {
        result = self.hasSharePdfReportsAvailable;
    } else {
        result = [iapProduct.purchasedFlag boolValue];
    }
    return result;
}

- (void)buyProduct:(SKProduct *)product {
    
    DLog(@"Buying %@...", product.productIdentifier);
    SKMutablePayment *muty = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:muty];
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    DLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    DLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    DLog(@"failedTransaction...");
    NSDictionary *userErrorInfo = nil;
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        DLog(@"Transaction error: %@", transaction.error.localizedDescription);
        [self diagTranslateTxnErrorCode:transaction.error.code];
        userErrorInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction.error, kIAPPurchaseError, nil];
    } else {
        [self diagTranslateTxnErrorCode:transaction.error.code];
        userErrorInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction.error, kIAPTxnCancelled, nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPManagerProductPurchasedNotification
                                                        object:transaction.payment.productIdentifier
                                                      userInfo:userErrorInfo];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) diagTranslateTxnErrorCode:(int)code {
    NSString *errorText = nil;
    switch (code) {
        case SKErrorUnknown:
            errorText = @"SKErrorUnknown";
            break;
        case SKErrorClientInvalid:
            errorText = @"SKErrorClientInvalid";
            break;
        case SKErrorPaymentCancelled:
            errorText = @"SKErrorPaymentCancelled";
            break;
        case SKErrorPaymentInvalid:
            errorText = @"SKErrorPaymentInvalid";
            break;
        case SKErrorPaymentNotAllowed:
            errorText = @"SKErrorPaymentNotAllowed";
            break;
        case SKErrorStoreProductNotAvailable:
            errorText = @"SKErrorStoreProductNotAvailable";
            break;
        default:
            errorText = @"SK does not know!";
            break;
    }
    DLog(@"SKPaymentTransaction.error.code xlates to %@", errorText);
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    NSNumber *creditsToAdd = nil;
    if ([productIdentifier isEqualToString:kSharePdfReport5Feature]) {
        [self pdfTokensAvailable];
        creditsToAdd = @5;
    } else if ([productIdentifier isEqualToString:kSharePdfReport10Feature]) {
        [self pdfTokensAvailable];
        creditsToAdd = @10;
    } else if ([productIdentifier isEqualToString:kSharePdfReport25Feature]) {
        [self pdfTokensAvailable];
        creditsToAdd = @25;
    }
    if (nil != creditsToAdd) {
        [self addCreditTransaction:creditsToAdd];
    }
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPManagerProductPurchasedNotification object:productIdentifier userInfo:nil];
}


#pragma mark - IAP Management Methods

- (void) productWithProductId:(NSString*)productId successHandler:(IAPSuccessHandler)successHandler failureHandler:(IAPFailureHandler)failureHandler {
    NSSet * productIdSet = [NSSet setWithObjects:
                                  productId,
                                  nil];
    [self productsWithProductIdSet:productIdSet successHandler:successHandler failureHandler:failureHandler];
}

- (void) productsWithProductIdSet:(NSSet*)productIdSet successHandler:(IAPSuccessHandler)successHandler failureHandler:(IAPFailureHandler)failureHandler {
    _successHandler = [successHandler copy];
    _failureHandler = [failureHandler copy];
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
    request.delegate = self;
    [request start];
}

#pragma mark - Diagonstic methods

- (void) resetTokenCount
{
    DLog(@"resetTokenCount called");
    
//    [self resetSeededCredits];
    [self.managedObjectContext performBlockAndWait:^{

//        [self setCreditBalanceToZero];
//        [self resetIndexStoreAndKeyValueStore];
        
    }];

    [self resetIAPAll];
}

- (void) diagDumpAction
{
    __block NSArray *diagList = nil;
    [self.managedObjectContext performBlockAndWait:^{
        
        diagList = [WCIAPTransaction enumerateTransactions:self.managedObjectContext persistentStore:self.store];
        DLog(@"total of %i WCIAPTransactions", [diagList count]);
        [diagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WCIAPTransaction *txn = (WCIAPTransaction *)obj;
            DLog(@"txnId: %@ has count of %i and a flag of %i, startCredits: %i, txnDate: %@", [txn txnId], [[txn credits] integerValue], [[txn flags] integerValue], [[txn startupCredits] integerValue], [txn txnDate]);
        }];

    }];
    
    NSUbiquitousKeyValueStore *ukvStore = [NSUbiquitousKeyValueStore defaultStore];
    id ukvObj = [ukvStore objectForKey:kIAPDeviceTransactionAggregate];
    if (nil != ukvObj) {
        DLog(@"ubiquitous kIAPDeviceTransactionAggregate keystore has a count of %i", [ukvObj count]);
        for (NSString *key in ukvObj) {
            IAPDeviceTransactionAggregate *creditTxn = [IAPDeviceTransactionAggregate unarchive:[ukvObj objectForKey:key]];
            DLog(@"IAPDeviceTransactionAggregate deviceId: %@, aggregatedCredits: %i, lastUpdated: %@",
                  [creditTxn deviceId], [[creditTxn aggregatedCredits] integerValue], [creditTxn lastUpdated]);
        }
    } else {
        DLog(@"ubiquitous IAPDeviceTransactionAggregate keystore is nil");
    }
}

- (void) resetIAPAll
{
    // remove credit transactions in index key store
    __weak __typeof(self) weakSelf = self;
    [self.managedObjectContext performBlockAndWait:^{
        [weakSelf resetIndexStoreAndKeyValueStores];
    }];
}

- (void) resetIndexStoreAndKeyValueStores
{
    [WCIAPTransaction deleteAllTxns:self.managedObjectContext persistentStore:self.store];
    
    NSUbiquitousKeyValueStore *ukvStore = [NSUbiquitousKeyValueStore defaultStore];
    [ukvStore removeObjectForKey:kIAPDeviceTransactionAggregate];
    [ukvStore synchronize];
}

- (void)setCreditBalanceToZero
{
    NSInteger creditCount = self.pdfTokensAvailable;
    creditCount *= -1;
    [self addCreditTransaction:[[NSNumber alloc] initWithInteger:creditCount]];
    NSUbiquitousKeyValueStore *ukvStore = [NSUbiquitousKeyValueStore defaultStore];
    [ukvStore synchronize];
}

#pragma mark - Credit Manipulation methods

- (NSInteger) pdfTokensAvailable
{
    __block NSInteger result = 0;
    if ([self isStoreAvailable]) {
        __weak __typeof(self) weakSelf = self;
        [self.managedObjectContext performBlockAndWait:^{
            // gather values from indexed store
            result = [[WCIAPTransaction sumTokens:weakSelf.managedObjectContext persistentStore:weakSelf.store] integerValue];
            NSString *deviceId = [weakSelf getIAPDeviceGuid];
            // add in aggregated values from other devices
            NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
            NSDictionary* txnHash = (NSDictionary*)[store objectForKey:kIAPDeviceTransactionAggregate];
            if (nil != txnHash) {
                for (NSString *key in txnHash) {
                    NSData *encodedTxn = [txnHash objectForKey:key];
                    IAPDeviceTransactionAggregate *txn = [IAPDeviceTransactionAggregate unarchive:encodedTxn];
                    // don't include your device id in the count
                    if (![deviceId isEqualToString:[txn deviceId]]) {
                        result = result + [[txn aggregatedCredits] integerValue];
                    }
                }
            }
            // add in startup credits
            result = result + kStartupCreditAmount;
        }];
    }
    return result;
}

- (NSDate *)lastCreditPurchaseDate
{
    __block NSDate *resultDate = nil;
    __weak __typeof(self) weakSelf = self;
    [self.managedObjectContext performBlockAndWait:^{
        resultDate = [WCIAPTransaction lastPurchasedCreditDate:weakSelf.managedObjectContext persistentStore:weakSelf.store];
    }];
    
    return resultDate;
}

- (BOOL)hasSharePdfReportsAvailable {
    NSInteger creditsAvailable = self.pdfTokensAvailable;
    return (creditsAvailable > 0);
}

- (void) sharePdfReportCreditHasBeenUsed {
    [self addCreditTransaction:[[NSNumber alloc] initWithInteger:-1]];
}

- (WCIAPTransaction *) addCreditTransaction:(NSNumber *)credits
{
    return [self addCreditTransaction:credits startupCredits:NO];
}

- (WCIAPTransaction *) addCreditTransaction:(NSNumber *)credits startupCredits:(BOOL)startupCredits
{
    __block WCIAPTransaction *iapTxn = nil;
    if ([self isStoreAvailable]) {
        __weak __typeof(self) weakSelf = self;
        [self.managedObjectContext performBlockAndWait:^{
            iapTxn = [WCIAPTransaction instanceWithManagedObjectContext:weakSelf.managedObjectContext persistentStore:weakSelf.store credits:credits startupCredits:startupCredits];
            // save
            [WCUtilities saveContextToStore:weakSelf.managedObjectContext];
        }];
        [weakSelf updateAggregateTotalForDevice];
    } else {
        DLog(@"IAPManager store not available at addCreditTransaction time.");
        abort();
    }
    return iapTxn;
}

- (void) updateAggregateTotalForDevice
{
    if ([self isStoreAvailable]) {
        __weak __typeof(self) weakSelf = self;
        [self.managedObjectContext performBlockAndWait:^{
            NSNumber *numberOfCredits = [WCIAPTransaction sumTokens:weakSelf.managedObjectContext persistentStore:weakSelf.store];
            NSString *deviceId = [weakSelf getIAPDeviceGuid];
            NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
            NSDictionary* immutableHash = (NSDictionary*)[store objectForKey:kIAPDeviceTransactionAggregate];
            NSMutableDictionary *txnHash = [[NSMutableDictionary alloc] initWithDictionary:immutableHash];
            if (nil == txnHash) {
                txnHash = [(NSMutableDictionary *)[NSMutableDictionary alloc]init];
            }
            NSData *encodedTxn = [txnHash objectForKey:deviceId];
            if (nil == encodedTxn) {
                NSString *startupTxnId = nil;
                NSDate *startupTxnDate = nil;
                WCIAPTransaction *startupCredits = [WCIAPTransaction startupCredits:weakSelf.managedObjectContext persistentStore:weakSelf.store];
                if (nil == startupCredits) {
                    startupTxnId = [startupCredits txnId];
                    startupTxnDate = [startupCredits txnDate];
                }
                IAPDeviceTransactionAggregate *aggregateTxn =
                    [[IAPDeviceTransactionAggregate alloc] initWithDeviceId:deviceId aggregatedCredits:numberOfCredits];
                encodedTxn = [aggregateTxn archive];
            } else {
                IAPDeviceTransactionAggregate *txn = [IAPDeviceTransactionAggregate unarchive:encodedTxn];
                
                [txn setAggregatedCredits:numberOfCredits];
                encodedTxn = [txn archive];
            }
            [txnHash setValue:encodedTxn forKey:deviceId];
            immutableHash = [[NSDictionary alloc] initWithDictionary:txnHash];
            [store setObject:immutableHash forKey:kIAPDeviceTransactionAggregate];
            [store synchronize];
        }];
    }
}

-(NSString *)getIAPDeviceGuid
{
    if (nil == _deviceId) {
        if (![self deviceIdFileExists]) {
            // create the iap device id file
            [self writeDeviceIdToFile:[[NSUUID UUID] UUIDString]];
        }
        _deviceId = [self readDeviceIdFromFile];
    }
    return _deviceId;
}

// writes string to text file
-(void) writeDeviceIdToFile:(NSString *)deviceId
{
    NSString *fileName = [IAPManager deviceIdFilename];
    [deviceId writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    
}

-(NSString *) readDeviceIdFromFile
{
    NSString *fileName = [IAPManager deviceIdFilename];
    NSString *deviceId = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    return deviceId;
}
-(BOOL) deviceIdFileExists
{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[IAPManager deviceIdFilename]];
    return fileExists;
}
+(NSString *)deviceIdFilename
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", documentsDirectory, kIAPDeviceId];
    return fileName;
}

- (void) recordCredits:(IAPCreditTransaction *)inboundTxn
{
    WCIAPTransaction *iapTxn = [inboundTxn makeIapTransaction:self.managedObjectContext store:self.store];

    [iapTxn setKeyValueStoreTransmittedFlag:YES];
    // save
    [WCUtilities saveContextToStore:self.managedObjectContext];
    
}

- (BOOL) isStoreAvailable
{
    BOOL result = NO;
    if (nil != self.managedObjectContext && nil != self.store) {
        result = YES;
    }
    return result;
}

- (void)handleExternalChangeNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSInteger reason = [[userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey] intValue];
    if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
        // get changed keys
        NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        for (NSString *key in changedKeys) {
            if ([kIAPDeviceTransactionAggregate isEqualToString:key]) {
                [self updateAggregateTotalForDevice];
            }
        }
    }
    switch (reason) {
        case NSUbiquitousKeyValueStoreServerChange: {
            DLog(@"handleExternalChangeNotification: reason: NSUbiquitousKeyValueStoreServerChange");
            break;
        }
        case NSUbiquitousKeyValueStoreInitialSyncChange: {
            DLog(@"handleExternalChangeNotification: reason: NSUbiquitousKeyValueStoreInitialSyncChange");
            break;
        }
        case NSUbiquitousKeyValueStoreQuotaViolationChange: {
            DLog(@"handleExternalChangeNotification: reason: NSUbiquitousKeyValueStoreQuotaViolationChange");
            break;
        }
    }
    
}

@end

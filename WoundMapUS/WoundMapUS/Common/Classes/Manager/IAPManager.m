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
#import "WMPaymentTransaction.h"
#import "WMTeam.h"
#import "WMParticipant.h"
#import "IAPProduct.h"
#import "WMIAPTransaction.h"
#import "IAPDeviceTransactionAggregate.h"
#import "WMIAPCreditTransaction.h"
#import "WMIAPTransaction.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"
#import "CoreDataHelper.h"

NSString *const kSharePdfReport5Feature = IAP_PDF5;
NSString *const kSharePdfReport10Feature = IAP_PDF10;
NSString *const kSharePdfReport25Feature = IAP_PDF25;

NSString *const kPatientCredit5Feature = IAP_PATIENT5;
NSString *const kPatientCredit25Feature = IAP_PATIENT25;
NSString *const kPatientCredit100Feature = IAP_PATIENT100;

NSString *const kTeamMemberProductIdentifier = IAP_TEAM;
NSString *const kCreateConsultingGroupProductIdentifier = IAP_CONSULT;

NSString *const kIAPManagerProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const kIAPPurchaseError = @"IAPPurchaseError";
NSString *const kIAPTxnCancelled = @"IAPTxnCancelled";

NSString *const kIAPDeviceTransactionAggregate = @"IAPDeviceTransactionAggregate";
int kStartupCreditAmount = 20;   // DEPLOYMENT: set to 20 on deplay

NSString *const kIAPDeviceId = @"iap-device-id.txt";

@interface IAPManager ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *sharedPDFReportProductIdentifiers;
@property (strong, nonatomic) NSArray *patientCreditProductIdentifiers;

@property (strong, nonatomic) SKPaymentQueue *paymentQueue;
@property (strong, nonatomic) NSArray *transactions;

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
        SharedInstance.sharedPDFReportProductIdentifiers = @[kSharePdfReport5Feature, kSharePdfReport10Feature, kSharePdfReport25Feature];
        SharedInstance.patientCreditProductIdentifiers = @[kPatientCredit5Feature, kPatientCredit25Feature, kPatientCredit100Feature];
        __weak __typeof(SharedInstance) weakSelf = SharedInstance;
        [[NSNotificationCenter defaultCenter] addObserverForName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
                                                          [weakSelf handleExternalChangeNotification:notification];
                                                      }];
        
    });
    return SharedInstance;
}

- (void)processPendingTransactions
{
    if (_paymentQueue && [_transactions count]) {
        [self paymentQueue:_paymentQueue updatedTransactions:_transactions];
    }
    _paymentQueue = nil;
    _transactions = nil;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (CoreDataHelper *)coreDataHelper
{
    return self.appDelegate.coreDataHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataHelper.context;
}

- (id)init {

    if ((self = [super init])) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray *skProducts = [response.products copy];
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    if (_successHandler) {
        _successHandler(skProducts);
        _successHandler = nil;
    }
    _failureHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    NSLog(@"Failed to load list of products. - error.description is - %@", error.description);
    if (_failureHandler) {
        _failureHandler(error);
        _failureHandler = nil;
    }
    _successHandler = nil;
}

#pragma mark - SKPaymentTransactionObserver

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Failed to restore transactions. - error.description is - %@", error.description);
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"Succeeded to restore transactions.");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSString *username = self.appDelegate.participant.userName;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    // transactions can come in before sign-in, cache and how we can catch up
    if (!ff.loggedIn) {
        _paymentQueue = queue;
        _transactions = transactions;
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    for (SKPaymentTransaction *transaction in transactions) {
        if (nil == [transaction transactionIdentifier]) {
            // no action required - we are not updating the UI here
            continue;
        }
        // persist to back end
        WM_ASSERT_MAIN_THREAD;
        WMPaymentTransaction *originalPaymentTransaction = nil;
        if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            SKPaymentTransaction *originalTransaction = transaction.originalTransaction;
            if (originalTransaction) {
                originalPaymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:originalTransaction
                                                                                         originalTransaction:nil
                                                                                                    username:username
                                                                                                      create:NO
                                                                                        managedObjectContext:managedObjectContext];
                if (nil == originalPaymentTransaction) {
                    // must get from back end first
                    NSError *localError = nil;
                    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMPaymentTransaction entityName]] error:&localError];
                    if (localError) {
                        [WMUtilities logError:localError];
                    }
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    originalPaymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:originalTransaction
                                                                                             originalTransaction:nil
                                                                                                        username:username
                                                                                                          create:NO
                                                                                            managedObjectContext:managedObjectContext];
                }
            }
        }
        WMPaymentTransaction *paymentTransaction = [WMPaymentTransaction paymentTransactionForSKPaymentTransaction:transaction
                                                                                               originalTransaction:originalPaymentTransaction
                                                                                                          username:self.appDelegate.participant.userName
                                                                                                            create:YES
                                                                                              managedObjectContext:managedObjectContext];
        FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchasing:
                    break;
                case SKPaymentTransactionStateDeferred:
                    break;
                case SKPaymentTransactionStatePurchased:
                    [weakSelf completeTransaction:transaction];
                    break;
                case SKPaymentTransactionStateFailed:
                    [weakSelf failedTransaction:transaction];
                    break;
                case SKPaymentTransactionStateRestored:
                    [weakSelf restoreTransaction:transaction];
            }
        };
        if (paymentTransaction.ffUrl) {
            [ff updateObj:paymentTransaction
               onComplete:onComplete onOffline:onComplete];
        } else {
            [ff createObj:paymentTransaction
                    atUri:[NSString stringWithFormat:@"/%@", [WMPaymentTransaction entityName]]
               onComplete:onComplete onOffline:onComplete];
        }
    }
}

- (BOOL)isProductPurchased:(IAPProduct *)iapProduct
{
    BOOL result = NO;
    if (iapProduct.aggregatorFlag) {
        result = (self.appDelegate.participant.reportTokenCountValue > 0);
    } else {
        result = iapProduct.purchasedFlagValue;
    }
    return result;
}

- (void)buyProduct:(SKProduct *)product
{
    [self buyProduct:product quantity:1];
}

- (void)buyProduct:(SKProduct *)product quantity:(NSInteger)quantity
{
    NSLog(@"Buying %@...", product.productIdentifier);
    SKMutablePayment *muty = [SKMutablePayment paymentWithProduct:product];
    muty.quantity = quantity;
    [[SKPaymentQueue defaultQueue] addPayment:muty];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPManagerProductPurchasedNotification
                                                        object:transaction
                                                      userInfo:nil];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPManagerProductPurchasedNotification
                                                        object:transaction
                                                      userInfo:nil];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction...");
    NSDictionary *userErrorInfo = nil;
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        [self diagTranslateTxnErrorCode:transaction.error.code];
        userErrorInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction.error, kIAPPurchaseError, nil];
    } else {
        [self diagTranslateTxnErrorCode:transaction.error.code];
        userErrorInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction.error, kIAPTxnCancelled, nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPManagerProductPurchasedNotification
                                                        object:transaction
                                                      userInfo:userErrorInfo];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) diagTranslateTxnErrorCode:(NSInteger)code
{
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
    NSLog(@"SKPaymentTransaction.error.code xlates to %@", errorText);
}

- (void)provideContentForPDFReportProductIdentifier:(SKPaymentTransaction *)transaction
{
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSNumber *creditsToAdd = nil;
    if ([productIdentifier isEqualToString:kSharePdfReport5Feature]) {
        creditsToAdd = @5;
    } else if ([productIdentifier isEqualToString:kSharePdfReport10Feature]) {
        creditsToAdd = @10;
    } else if ([productIdentifier isEqualToString:kSharePdfReport25Feature]) {
        creditsToAdd = @25;
    }
    WMParticipant *participant = self.appDelegate.participant;
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSString *uri = [participant.ffUrl stringByReplacingOccurrencesOfString:@"/ff/resources/" withString:@"/"];
    [ff getObjFromUri:uri onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [participant addReportTokens:[creditsToAdd integerValue]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [ff updateObj:participant error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
    }];
}

- (void)provideContentForTeamAddedProductIdentifier:(SKPaymentTransaction *)transaction
{
    // need to determine if the purchase has been applied, persist the transaction
    
}

- (void)provideContentForPatientCreditProductIdentifier:(SKPaymentTransaction *)transaction
{
    NSString *productIdentifier = transaction.payment.productIdentifier;
    int32_t creditsToAdd = 0;
    if ([productIdentifier isEqualToString:kPatientCredit5Feature]) {
        creditsToAdd = 5;
    } else if ([productIdentifier isEqualToString:kPatientCredit25Feature]) {
        creditsToAdd = 25;
    } else if ([productIdentifier isEqualToString:kPatientCredit100Feature]) {
        creditsToAdd = 100;
    }
    WMParticipant *participant = self.appDelegate.participant;
    WMTeam *team = participant.team;
    team.purchasedPatientCountValue = (team.purchasedPatientCountValue + creditsToAdd);
    NSManagedObjectContext *managedObjectContext = [participant managedObjectContext];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
    };
    [ff updateObj:team onComplete:onComplete onOffline:onComplete];
}

// called when purchase of IAP has successfully completed on iTunes store kit server
- (void)provideContentForProductIdentifier:(SKPaymentTransaction *)transaction
{
    NSString *productIdentifier = transaction.payment.productIdentifier;
    if ([_sharedPDFReportProductIdentifiers containsObject:productIdentifier]) {
        [self provideContentForPDFReportProductIdentifier:transaction];
    } else if ([productIdentifier isEqualToString:kTeamMemberProductIdentifier]) {
        [self provideContentForTeamAddedProductIdentifier:transaction];
    } else if ([_patientCreditProductIdentifiers containsObject:productIdentifier]) {
        [self provideContentForPatientCreditProductIdentifier:transaction];
    }
}

#pragma mark - IAP Management Methods

- (void)productWithProductId:(NSString *)productId
              successHandler:(IAPSuccessHandler)successHandler
              failureHandler:(IAPFailureHandler)failureHandler
{
    NSSet *productIdSet = [NSSet setWithObjects:productId, nil];
    [self productsWithProductIdSet:productIdSet successHandler:successHandler failureHandler:failureHandler];
}

- (void)productsWithProductIdSet:(NSSet *)productIdSet
                  successHandler:(IAPSuccessHandler)successHandler
                  failureHandler:(IAPFailureHandler)failureHandler
{
    _successHandler = [successHandler copy];
    _failureHandler = [failureHandler copy];
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
    request.delegate = self;
    [request start];
}

#pragma mark - Utilities

- (NSString *)updatePriceInString:(NSString *)string skProducts:(NSArray *)products
{
    NSInteger stringLength = [string length];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSRange range0 = NSMakeRange(0, stringLength);
    NSMutableArray *substrings = [NSMutableArray array];
    for (SKProduct *product in products) {
        [numberFormatter setLocale:product.priceLocale];
        NSRange range1 = [string rangeOfString:@"|" options:0 range:range0];
        if (range1.location == NSNotFound) {
            break;
        }
        // else
        NSRange substringRange = NSMakeRange(range0.location, range1.location - range0.location);
        [substrings addObject:[string substringWithRange:substringRange]];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
        [substrings addObject:formattedPrice];
        range0.location = range1.location + 1;
        range0.length = (stringLength - range0.location);
        range1 = [string rangeOfString:@"|" options:0 range:range0];
        range0.location = range1.location + 1;
        range0.length = (stringLength - range0.location);
    }
    // append remaining part of string
    [substrings addObject:[string substringWithRange:range0]];
    return [substrings componentsJoinedByString:@" "];;
}

#pragma mark - Diagonstic methods

- (void)resetTokenCount
{
    NSLog(@"resetTokenCount called");
    
//    [self resetSeededCredits];
    [self.managedObjectContext performBlockAndWait:^{

//        [self setCreditBalanceToZero];
//        [self resetIndexStoreAndKeyValueStore];
        
    }];

    [self resetIAPAll];
}

- (void)diagDumpAction
{
    __block NSArray *diagList = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    [managedObjectContext performBlockAndWait:^{
        diagList = [WMIAPTransaction enumerateTransactions:managedObjectContext];
        DLog(@"total of %lu WCIAPTransactions", (unsigned long)[diagList count]);
        [diagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WMIAPTransaction *txn = (WMIAPTransaction *)obj;
            DLog(@"txnId: %@ has count of %li and a flag of %li, startCredits: %li, txnDate: %@", [txn txnId], (long)[[txn credits] integerValue], (long)[[txn flags] integerValue], (long)[[txn startupCredits] integerValue], [txn txnDate]);
        }];
    }];
    
    NSUbiquitousKeyValueStore *ukvStore = [NSUbiquitousKeyValueStore defaultStore];
    id ukvObj = [ukvStore objectForKey:kIAPDeviceTransactionAggregate];
    if (nil != ukvObj) {
        DLog(@"ubiquitous kIAPDeviceTransactionAggregate keystore has a count of %lu", (unsigned long)[ukvObj count]);
        for (NSString *key in ukvObj) {
            IAPDeviceTransactionAggregate *creditTxn = [IAPDeviceTransactionAggregate unarchive:[ukvObj objectForKey:key]];
            DLog(@"IAPDeviceTransactionAggregate deviceId: %@, aggregatedCredits: %li, lastUpdated: %@",
                  [creditTxn deviceId], (long)[[creditTxn aggregatedCredits] integerValue], [creditTxn lastUpdated]);
        }
    } else {
        DLog(@"ubiquitous IAPDeviceTransactionAggregate keystore is nil");
    }
}

- (void)resetIAPAll
{
    // remove credit transactions in index key store
    __weak __typeof(&*self)weakSelf = self;
    [self.managedObjectContext performBlockAndWait:^{
        [weakSelf resetIndexStoreAndKeyValueStores];
    }];
}

- (void)resetIndexStoreAndKeyValueStores
{
    [WMIAPTransaction deleteAllTxns:self.managedObjectContext];
    NSUbiquitousKeyValueStore *ukvStore = [NSUbiquitousKeyValueStore defaultStore];
    [ukvStore removeObjectForKey:kIAPDeviceTransactionAggregate];
    [ukvStore synchronize];
}

- (void)setCreditBalanceToZero
{
    IAPTokenCountHandler completionHandler = ^(NSError *error, NSInteger tokenCount, NSDate *lastTokenCreditPurchaseDate) {
        tokenCount *= -1;
        [self addCreditTransaction:@(tokenCount)];
        NSUbiquitousKeyValueStore *ukvStore = [NSUbiquitousKeyValueStore defaultStore];
        [ukvStore synchronize];
    };
    [self pdfTokensAvailable:completionHandler];
}

#pragma mark - Credit Manipulation methods

- (void)pdfTokensAvailable:(IAPTokenCountHandler)completionHandler
{
    // first update from back end
    WMParticipant *participant = self.appDelegate.participant;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSString *uri = [participant.ffUrl stringByReplacingOccurrencesOfString:@"/ff/resources/" withString:@"/"];
    [ff getObjFromUri:uri onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        completionHandler(error, participant.reportTokenCountValue, participant.lastTokenCreditPurchaseDate);
    }];
}

- (NSDate *)lastCreditPurchaseDate
{
    __block NSDate *resultDate = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    [managedObjectContext performBlockAndWait:^{
        resultDate = [WMIAPTransaction lastPurchasedCreditDate:managedObjectContext];
    }];
    
    return resultDate;
}
- (void)sharePdfReportCreditHasBeenUsed
{
    WMParticipant *participant = self.appDelegate.participant;
    participant.reportTokenCountValue = (participant.reportTokenCountValue - 1);
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSError *error = nil;
    [ff updateObj:participant error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
}

- (WMIAPTransaction *) addCreditTransaction:(NSNumber *)credits
{
    return [self addCreditTransaction:credits startupCredits:NO];
}

- (WMIAPTransaction *) addCreditTransaction:(NSNumber *)credits startupCredits:(BOOL)startupCredits
{
    __block WMIAPTransaction *iapTxn = nil;
    if ([self isStoreAvailable]) {
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        [managedObjectContext performBlockAndWait:^{
            iapTxn = [WMIAPTransaction instanceWithManagedObjectContext:managedObjectContext credits:credits startupCredits:startupCredits];
            // save
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }];
        [self updateAggregateTotalForDevice];
    } else {
        DLog(@"IAPManager store not available at addCreditTransaction time.");
        abort();
    }
    return iapTxn;
}

- (void) updateAggregateTotalForDevice
{
    if ([self isStoreAvailable]) {
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        __weak __typeof(&*self)weakSelf = self;
        [managedObjectContext performBlockAndWait:^{
            NSNumber *numberOfCredits = [WMIAPTransaction sumTokens:managedObjectContext];
            NSString *deviceId = [weakSelf getIAPDeviceGuid];
            NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
            NSDictionary* immutableHash = (NSDictionary*)[keyValueStore objectForKey:kIAPDeviceTransactionAggregate];
            NSMutableDictionary *txnHash = [[NSMutableDictionary alloc] initWithDictionary:immutableHash];
            if (nil == txnHash) {
                txnHash = [(NSMutableDictionary *)[NSMutableDictionary alloc]init];
            }
            NSData *encodedTxn = [txnHash objectForKey:deviceId];
            if (nil == encodedTxn) {
                NSString *startupTxnId = nil;
                NSDate *startupTxnDate = nil;
                WMIAPTransaction *startupCredits = [WMIAPTransaction startupCredits:managedObjectContext];
                if (nil == startupCredits) {
                    startupTxnId = [startupCredits txnId];
                    startupTxnDate = [startupCredits txnDate];
                }
                IAPDeviceTransactionAggregate *aggregateTxn = [[IAPDeviceTransactionAggregate alloc] initWithDeviceId:deviceId aggregatedCredits:numberOfCredits];
                encodedTxn = [aggregateTxn archive];
            } else {
                IAPDeviceTransactionAggregate *txn = [IAPDeviceTransactionAggregate unarchive:encodedTxn];
                [txn setAggregatedCredits:numberOfCredits];
                encodedTxn = [txn archive];
            }
            [txnHash setValue:encodedTxn forKey:deviceId];
            immutableHash = [[NSDictionary alloc] initWithDictionary:txnHash];
            [keyValueStore setObject:immutableHash forKey:kIAPDeviceTransactionAggregate];
            [keyValueStore synchronize];
        }];
    }
}

- (NSString *)getIAPDeviceGuid
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
- (void)writeDeviceIdToFile:(NSString *)deviceId
{
    NSString *fileName = [IAPManager deviceIdFilename];
    [deviceId writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:NULL];
    
}

- (NSString *)readDeviceIdFromFile
{
    NSString *fileName = [IAPManager deviceIdFilename];
    NSString *deviceId = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:NULL];
    return deviceId;
}

- (BOOL)deviceIdFileExists
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

- (void)recordCredits:(WMIAPCreditTransaction *)inboundTxn
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    WMIAPTransaction *iapTxn = [inboundTxn makeIapTransaction:managedObjectContext];
    [iapTxn setKeyValueStoreTransmittedFlag:YES];
    // save
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (BOOL)isStoreAvailable
{
    BOOL result = NO;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (nil != managedObjectContext) {
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
            NSLog(@"handleExternalChangeNotification: reason: NSUbiquitousKeyValueStoreServerChange");
            break;
        }
        case NSUbiquitousKeyValueStoreInitialSyncChange: {
            NSLog(@"handleExternalChangeNotification: reason: NSUbiquitousKeyValueStoreInitialSyncChange");
            break;
        }
        case NSUbiquitousKeyValueStoreQuotaViolationChange: {
            NSLog(@"handleExternalChangeNotification: reason: NSUbiquitousKeyValueStoreQuotaViolationChange");
            break;
        }
    }
    
}

@end

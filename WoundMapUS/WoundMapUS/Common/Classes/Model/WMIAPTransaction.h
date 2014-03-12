#import "_WMIAPTransaction.h"

@interface WMIAPTransaction : _WMIAPTransaction {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               credits:(NSNumber *)credits;
+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               credits:(NSNumber *)credits
                        startupCredits:(BOOL)startupCredits;

+ (NSNumber *)sumTokens:(NSManagedObjectContext *)managedObjectContext;
+ (NSDate *)lastPurchasedCreditDate:(NSManagedObjectContext *)managedObjectContext;
+ (NSUInteger)transactionCount:(NSManagedObjectContext *)managedObjectContext;
+ (WMIAPTransaction *)transactionWithId:(NSString *)txnId managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)creditTransactionsNotTransmitted:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL) hasStartupCredits:(NSManagedObjectContext *)managedObjectContext;
+ (WMIAPTransaction *) startupCredits:(NSManagedObjectContext *)managedObjectContext;

+ (void)deleteTransaction:(NSManagedObjectContext *)managedObjectContext transaction:(WMIAPTransaction *) transaction;

+ (void)deleteAllTxns:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)enumerateTransactions:(NSManagedObjectContext *)managedObjectContext;


- (BOOL)hasBeenKeyValueStoreTransmitted;
- (void)setKeyValueStoreTransmittedFlag:(BOOL)kvsTransmittedFlag;
//- (BOOL) isStartupCreditTransaction;
//+ (BOOL) isStartupCreditTransaction:(NSNumber *)flags;
//- (void)setStartupCreditTransaction:(BOOL)startupCreditsFlag;

@end

#import "_WMIAPTransaction.h"

@interface WMIAPTransaction : _WMIAPTransaction {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
                               credits:(NSNumber *)credits;
+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
                               credits:(NSNumber *)credits
                        startupCredits:(BOOL)startupCredits;

+ (NSNumber *)sumTokens:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (NSDate *)lastPurchasedCreditDate:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (NSUInteger)transactionCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMIAPTransaction *)transactionWithId:(NSString *)txnId managedObjectContext:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (NSArray *)creditTransactionsNotTransmitted:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (BOOL) hasStartupCredits:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMIAPTransaction *) startupCredits:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (void)deleteTransaction:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store transaction:(WMIAPTransaction *) transaction;

+ (void)deleteAllTxns:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (NSArray *)enumerateTransactions:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;


- (BOOL)hasBeenKeyValueStoreTransmitted;
- (void)setKeyValueStoreTransmittedFlag:(BOOL)kvsTransmittedFlag;
//- (BOOL) isStartupCreditTransaction;
//+ (BOOL) isStartupCreditTransaction:(NSNumber *)flags;
//- (void)setStartupCreditTransaction:(BOOL)startupCreditsFlag;

@end

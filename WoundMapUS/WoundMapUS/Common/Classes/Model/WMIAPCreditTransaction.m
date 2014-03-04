//
//  IAPTokenTransaction.m
//  WoundMAP
//
//  Created by John Scarpaci on 11/13/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMIAPCreditTransaction.h"
#import "WCIAPTransaction+Custom.h"

@implementation WMIAPCreditTransaction


- (id)initWithTransactionCredits:(NSNumber *)credits {
    
    if ((self = [super init])) {
        _txnId = [[NSUUID UUID] UUIDString];
        _credits = credits;
        _flags = [NSNumber numberWithInteger:0];
        _txnDate = [NSDate date];
        _startupCredits = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_txnId forKey:@"txnId"];
    [coder encodeObject:_credits forKey:@"credits"];
    [coder encodeObject:_flags forKey:@"flags"];
    [coder encodeObject:_txnDate forKey:@"txnDate"];
    [coder encodeObject:_startupCredits forKey:@"startupCredits"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _txnId = [coder decodeObjectForKey:@"txnId"];
        _credits = [coder decodeObjectForKey:@"credits"];
        _flags = [coder decodeObjectForKey:@"flags"];
        _txnDate = [coder decodeObjectForKey:@"txnDate"];
        _startupCredits = [coder decodeObjectForKey:@"startupCredits"];
    }
    return self;
}

+ (WMIAPCreditTransaction *)makeCreditTransaction:(WCIAPTransaction *)iapTransaction
{
    WMIAPCreditTransaction *creditTransaction = [[WMIAPCreditTransaction alloc] initWithTransactionCredits:[iapTransaction credits]];
    [creditTransaction setTxnId:[iapTransaction txnId]];
    [creditTransaction setFlags:[iapTransaction flags]];
    [creditTransaction setTxnDate:[iapTransaction txnDate]];
    [creditTransaction setStartupCredits:[iapTransaction startupCredits]];
    return creditTransaction;
}

- (WCIAPTransaction *)makeIapTransaction:(NSManagedObjectContext *)managedObjectContext store:(NSPersistentStore *)store
{
    WCIAPTransaction *iapTxn = [WCIAPTransaction instanceWithManagedObjectContext:managedObjectContext persistentStore:store credits:[self credits]];
    [iapTxn setTxnId: [self txnId]];
    [iapTxn setFlags:[self flags]];
    [iapTxn setTxnDate:[self txnDate]];
    [iapTxn setStartupCredits:[self startupCredits]];
    return iapTxn;
}

@end

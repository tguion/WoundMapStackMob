//
//  WMIAPCreditTransaction.h
//  WoundMAP
//
//  Created by John Scarpaci on 11/13/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCIAPTransaction.h"

@interface WMIAPCreditTransaction : NSObject

@property (nonatomic, strong) NSString *txnId;
@property (nonatomic) NSNumber *credits;
@property (nonatomic) NSNumber *flags;
@property (nonatomic, retain) NSDate *txnDate;
@property (nonatomic, retain) NSNumber *startupCredits;



- (id)initWithTransactionCredits:(NSNumber *)credits;
// makes a non core data IAP credit transaction
+ (WMIAPCreditTransaction *)makeCreditTransaction:(WCIAPTransaction *)iapTransaction;

// makes a core data IAP credit transaction -- could not figure out how to deserialize
// WCIAPTransaction so using WMIAPCreditTransaction for serialization purposes.
- (WCIAPTransaction *)makeIapTransaction:(NSManagedObjectContext *)managedObjectContext store:(NSPersistentStore *)store;

@end

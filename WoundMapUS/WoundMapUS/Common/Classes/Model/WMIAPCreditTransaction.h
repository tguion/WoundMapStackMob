//
//  WMIAPCreditTransaction.h
//  WoundMAP
//
//  Created by John Scarpaci on 11/13/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMIAPTransaction.h"

@interface WMIAPCreditTransaction : NSObject

@property (nonatomic, strong) NSString *txnId;
@property (nonatomic) NSNumber *credits;
@property (nonatomic) NSNumber *flags;
@property (nonatomic, retain) NSDate *txnDate;
@property (nonatomic, retain) NSNumber *startupCredits;



- (id)initWithTransactionCredits:(NSNumber *)credits;
// makes a non core data IAP credit transaction
+ (WMIAPCreditTransaction *)makeCreditTransaction:(WMIAPTransaction *)iapTransaction;

// makes a core data IAP credit transaction -- could not figure out how to deserialize
// WMIAPTransaction so using WMIAPCreditTransaction for serialization purposes.
- (WMIAPTransaction *)makeIapTransaction:(NSManagedObjectContext *)managedObjectContext store:(NSPersistentStore *)store;

@end

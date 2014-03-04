//
//  IAPDeviceTransactionAggregate.h
//  WoundMAP
//
//  Created by John Scarpaci on 12/6/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMIAPTransaction.h"

@interface IAPDeviceTransactionAggregate : NSObject

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic) NSNumber *aggregatedCredits;
@property (nonatomic, retain) NSDate *lastUpdated;

- (id)initWithDeviceId:(NSString*)deviceId
     aggregatedCredits:(NSNumber *)aggregatedCredits;

+(IAPDeviceTransactionAggregate *) initWith:(WMIAPTransaction *)iapTxn deviceId:(NSString*)deviceId;
-(WMIAPTransaction *)makeIAPTransaction:(NSManagedObjectContext *)managedObjectContext store:(NSPersistentStore *)store;

+(IAPDeviceTransactionAggregate *) unarchive:(NSData *)encodedTxn;
-(NSData *) archive;

@end

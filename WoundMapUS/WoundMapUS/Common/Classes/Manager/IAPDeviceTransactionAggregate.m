//
//  IAPDeviceTransactionAggregate.m
//  WoundMAP
//
//  Created by John Scarpaci on 12/6/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "IAPDeviceTransactionAggregate.h"
#import "WMIAPTransaction.h"

@implementation IAPDeviceTransactionAggregate


- (id)initWithDeviceId:(NSString*)deviceId
     aggregatedCredits:(NSNumber *)aggregatedCredits
{
    if ((self = [super init])) {
        _deviceId = deviceId;
        _aggregatedCredits = aggregatedCredits;
        _lastUpdated = [NSDate date];
    }
    return self;
}

+(IAPDeviceTransactionAggregate *) initWith:(WMIAPTransaction *)iapTxn deviceId:(NSString*)deviceId
{
    IAPDeviceTransactionAggregate *aggregateTxn =
        [[IAPDeviceTransactionAggregate alloc] initWithDeviceId:deviceId
                                              aggregatedCredits:[iapTxn credits]];
    return aggregateTxn;
}

-(WMIAPTransaction *)makeIAPTransaction:(NSManagedObjectContext *)managedObjectContext store:(NSPersistentStore *)store
{
    WMIAPTransaction *iapTxn = [WMIAPTransaction instanceWithManagedObjectContext:managedObjectContext
                                                                          credits:[self aggregatedCredits]
                                                                   startupCredits:YES];
    [iapTxn setTxnDate:[self lastUpdated]];
    return iapTxn;

}


+(IAPDeviceTransactionAggregate *) unarchive:(NSData *)encodedTxn
{
    IAPDeviceTransactionAggregate *txn = (IAPDeviceTransactionAggregate *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedTxn];
    return txn;
}

-(NSData *)archive
{
    NSData *encodedTxn = [NSKeyedArchiver archivedDataWithRootObject:self];
    return encodedTxn;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_deviceId forKey:@"deviceId"];
    [coder encodeObject:_aggregatedCredits forKey:@"aggregatedCredits"];
    [coder encodeObject:_lastUpdated forKey:@"lastUpdated"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _deviceId = [coder decodeObjectForKey:@"deviceId"];
        _aggregatedCredits = [coder decodeObjectForKey:@"aggregatedCredits"];
        _lastUpdated = [coder decodeObjectForKey:@"lastUpdated"];
    }
    return self;
}

@end

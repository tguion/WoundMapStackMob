//
//  WMSeedDatabaseManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMTeam;

@interface WMSeedDatabaseManager : NSObject

+ (WMSeedDatabaseManager *)sharedInstance;

- (void)seedLocalData:(NSManagedObjectContext *)managedObjectContext;
- (void)seedDatabaseWithCompletionHandler:(void (^)(NSError *))handler;

@end

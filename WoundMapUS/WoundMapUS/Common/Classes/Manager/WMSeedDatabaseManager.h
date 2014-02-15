//
//  WMSeedDatabaseManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMCoreDataStore;

@interface WMSeedDatabaseManager : NSObject

+ (WMSeedDatabaseManager *)sharedInstance;

- (void)seedTeamDatabaseWithCompletionHandler:(void (^)(NSError *))handler;

@end

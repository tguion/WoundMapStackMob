//
//  WMSeedDatabaseManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/15/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMTeam;

@interface WMSeedDatabaseManager : NSObject

+ (WMSeedDatabaseManager *)sharedInstance;

- (void)seedLocalData:(NSManagedObjectContext *)managedObjectContext;
- (void)seedNavigationTrackWithCompletionHandler:(void (^)(NSError *))handler;
- (void)seedDatabaseWithCompletionHandler:(void (^)(NSError *))handler;

@end

//
//  CoreDataHelper.h
//  Grocery Cloud
//
//  Created by Tim Roadley on 18/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MigrationVC.h"
#import "WMFFManagedObject.h"

@class WMNetworkReachability;

extern NSString *storeFilename;
extern NSString *sourceStoreFilename;
extern NSString *localStoreFilename;

@interface CoreDataHelper : NSObject <UIAlertViewDelegate,NSXMLParserDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, strong) WMNetworkReachability *networkMonitor;

@property (nonatomic, readonly) NSManagedObjectContext *parentContext;          // MagicalRecord private queue parent managedObjectContext
@property (nonatomic, readonly) NSManagedObjectContext *context;                // child context of parentContext managedObjectContext

@property (nonatomic, readonly) NSManagedObjectModel *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;      // coordinator for stores
@property (nonatomic, readonly) NSPersistentStore *store;                       // MagicalRecord default store

@property (nonatomic, readonly) BOOL seedDatabaseFound;                         // YES if we have a seed database

- (void)setupCoreData;

- (void)markBackendDataAcquiredForEntityName:(NSString *)entityName;
- (BOOL)isBackendDataAcquiredForEntityName:(NSString *)entityName;
- (void)unmarkBackendDataAcquiredForEntityName:(NSString *)entityName;

- (id<WMFFManagedObject>)ffManagedObjectForCollection:(NSString *)collection guid:(NSString *)guid managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

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

extern NSString *storeFilename;
extern NSString *sourceStoreFilename;
extern NSString *localStoreFilename;

@interface CoreDataHelper : NSObject <UIAlertViewDelegate,NSXMLParserDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSManagedObjectContext *parentContext;          // MagicalRecord private queue parent managedObjectContext
@property (nonatomic, readonly) NSManagedObjectContext *context;                // child context of parentContext managedObjectContext

@property (nonatomic, readonly) NSManagedObjectModel *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;      // coordinator for stores
@property (nonatomic, readonly) NSPersistentStore *store;                       // MagicalRecord default store

- (void)setupCoreData;

@end

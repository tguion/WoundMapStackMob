//
//  NSPersistentStoreCoordinator+MagicalRecord.h
//
//  Created by Saul Mora on 3/11/10.
//  Copyright 2010 Magical Panda Software, LLC All rights reserved.
//

#import "MagicalRecord.h"
#import "NSPersistentStore+MagicalRecord.h"

extern NSString * const kMagicalRecordPSCDidCompleteiCloudSetupNotification;

@interface NSPersistentStoreCoordinator (MagicalRecord)

+ (NSPersistentStoreCoordinator *) MR_defaultStoreCoordinator;
+ (void) MR_setDefaultStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;

+ (NSPersistentStoreCoordinator *) MR_coordinatorWithInMemoryStore;

+ (NSPersistentStoreCoordinator *) MR_newPersistentStoreCoordinator NS_RETURNS_RETAINED;

+ (NSPersistentStoreCoordinator *) MR_coordinatorWithSqliteStoreNamed:(id)storeFileName;
+ (NSPersistentStoreCoordinator *) MR_coordinatorWithAutoMigratingSqliteStoreNamed:(id)storeFileName;
+ (NSPersistentStoreCoordinator *) MR_coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore;
+ (NSPersistentStoreCoordinator *) MR_coordinatorWithiCloudContainerID:(NSString *)containerID contentNameKey:(NSString *)contentNameKey localStoreNamed:(NSString *)localStoreName cloudStorePathComponent:(NSString *)subPathComponent;

+ (NSPersistentStoreCoordinator *) MR_coordinatorWithiCloudContainerID:(NSString *)containerID contentNameKey:(NSString *)contentNameKey localStoreNamed:(NSString *)localStoreName cloudStorePathComponent:(NSString *)subPathComponent completion:(void(^)(void))completionHandler;

- (NSPersistentStore *) MR_addInMemoryStore;
- (NSPersistentStore *) MR_addAutoMigratingSqliteStoreNamed:(id) storeFileName;
- (NSPersistentStore *) MR_addSqliteStoreNamed:(id)storeFileName withOptions:(__autoreleasing NSDictionary *)options;
- (NSPersistentStore *) MR_addSqliteStoreNamed:(id)storeFileName withOptions:(__autoreleasing NSDictionary *)options configuration:(NSString *)configuration;

- (void) MR_addiCloudContainerID:(NSString *)containerID contentNameKey:(NSString *)contentNameKey localStoreNamed:(NSString *)localStoreName cloudStorePathComponent:(NSString *)subPathComponent;
- (void) MR_addiCloudContainerID:(NSString *)containerID contentNameKey:(NSString *)contentNameKey localStoreNamed:(NSString *)localStoreName cloudStorePathComponent:(NSString *)subPathComponent completion:(void(^)(void))completionBlock;

@end

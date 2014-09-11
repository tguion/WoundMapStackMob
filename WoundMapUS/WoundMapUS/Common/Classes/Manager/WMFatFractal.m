//
//  WMFatFractal.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/4/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"

//static NSString *baseUrl = @"http://localhost:8080/WoundMapUS";//DEPLOYMENT
//static NSString *sslUrl = @"https://localhost:8443/WoundMapUS";
//static NSString *baseUrl = @"http://192.168.1.149:8080/WoundMapUS";//DEPLOYMENT
//static NSString *sslUrl = @"https://192.168.1.149:8443/WoundMapUS";
static NSString *baseUrl = @"http://mobilehealthware.fatfractal.com/WoundMapUS";
static NSString *sslUrl = @"https://mobilehealthware.fatfractal.com/WoundMapUS";

@implementation WMFatFractal

+ (WMFatFractal *)sharedInstance
{
    static WMFatFractal *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMFatFractal alloc] initWithBaseUrl:baseUrl sslUrl:sslUrl];
        [self initializeFatFractalInstance:SharedInstance];
    });
    return SharedInstance;
}

+ (WMFatFractal *)instance
{
    WMFatFractal *instance = [[WMFatFractal alloc] initWithBaseUrl:baseUrl sslUrl:sslUrl];
    [self initializeFatFractalInstance:instance];
    return instance;
}

+ (void)initializeFatFractalInstance:(WMFatFractal *)ff
{
    ff.debug = YES;//DEPLOYMENT
    ff.localStorage = [[FFLocalStorageSQLite alloc] initWithDatabaseKey:@"WoundMapFFStorage"];
    // must load blobs explicitely
    ff.autoLoadBlobs = NO;
    ff.autoLoadRefs = YES;
    ff.queueDelegate = [WMFatFractalManager sharedInstance];
}

- (id)findExistingObjectWithClass:(Class)clazz
                            ffUrl:(NSString *)ffUrl
             managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  persistentStore:(NSPersistentStore *)store
{
    __block id object = nil;
    [managedObjectContext performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(clazz) inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        if (store) {
            [request setAffectedStores:@[store]];
        }
        [request setPredicate:[NSPredicate predicateWithFormat:@"ffUrl == %@", ffUrl]];
        object = [NSManagedObject MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    }];
    return object;
}

/**
 * Let the FatFractal SDK know how to handle your CoreData objects, by creating a [custom FatFractal subclass]
 * This is the code that holds everything together. We're over-riding
 - (id) createInstanceOfClass:(Class) class forObjectWithMetaData:(FFMetaData *)objMetaData
 * so that when the FatFractal SDK needs to create an instance of one of your objects, then you can control how that's done.
 * In this example, then if it's an NSManagedObject subclass, we're first checking to see if we already have that object locally, and if not then we're calling the appropriate CoreData initializer.
 */

- (id)createInstanceOfClass:(Class)clazz forObjectWithMetaData:(FFMetaData *)objMetaData
{
    if ([clazz isSubclassOfClass:[NSManagedObject class]]) {
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        __block id object = nil;
        [managedObjectContext performBlockAndWait:^{
            object = [self findExistingObjectWithClass:clazz ffUrl:objMetaData.ffUrl managedObjectContext:managedObjectContext persistentStore:nil];
            if (object) {
                DLog(@"Found existing %@ object with ffUrl %@ in managed context", NSStringFromClass(clazz), objMetaData.ffUrl);
            } else {
                DLog(@"Inserting new %@ object with ffUrl %@ into managed context", NSStringFromClass(clazz), objMetaData.ffUrl);
                object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(clazz) inManagedObjectContext:managedObjectContext];
            }
        }];
        return object;
    }
    // else
    return [[clazz alloc] init];
}

@end

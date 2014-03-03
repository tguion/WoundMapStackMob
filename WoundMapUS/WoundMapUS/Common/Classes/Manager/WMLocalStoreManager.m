//
//  WMLocalStoreManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMLocalStoreManager.h"
#import "CoreDataHelper.h"
#import "WMBradenCare.h"
#import "WMWoundType.h"
#import "WMDefinition.h"
#import "WMInstruction.h"
#import "IAPProduct.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMLocalStoreManager ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;

@end

@implementation WMLocalStoreManager

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (CoreDataHelper *)coreDataHelper
{
    return self.appDelegate.coreDataHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataHelper.localContext;
}

- (NSPersistentStore *)store
{
    return self.coreDataHelper.localStore;
}

#pragma mark - Initialization

+ (WMLocalStoreManager *)sharedInstance
{
    static WMLocalStoreManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMLocalStoreManager alloc] init];
    });
    return SharedInstance;
}

- (void)seedLocalDatabase
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    [managedObjectContext performBlock:^{
        [WMBradenCare seedDatabase:managedObjectContext persistentStore:store];
        [WMDefinition seedDatabase:self.managedObjectContext persistentStore:self.store];
        [WMWoundType seedDatabase:self.managedObjectContext persistentStore:self.store];
        [IAPProduct seedDatabase:self.managedObjectContext persistentStore:self.store];
        [WMInstruction seedDatabase:self.managedObjectContext persistentStore:self.store];
        NSError *error = nil;
        [managedObjectContext saveAndWait:&error];
        if (nil != error) {
            [WMUtilities logError:error];
        }
    }];
}

#pragma mark - IAP

- (IAPProduct *)iapProductForIdentifier:(NSString *)identifier
{
    __block IAPProduct *product = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    [managedObjectContext performBlockAndWait:^{
        product = [IAPProduct productForIdentifier:identifier
                                            create:NO
                              managedObjectContext:managedObjectContext
                                   persistentStore:store];
    }];
    return product;
}

#pragma mark - BradenCare

- (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                      score:(NSInteger)score
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    __block WMBradenCare *bradenCare = nil;
    [managedObjectContext performBlockAndWait:^{
        bradenCare = [WMBradenCare bradenCareForSectionTitle:sectionTitle
                                                       score:[NSNumber numberWithInt:score]
                                        managedObjectContext:managedObjectContext
                                             persistentStore:store];
    }];
    return bradenCare;
}

@end

//
//  WMPatientManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientManager.h"
#import "WMPatient.h"
#import "WMNavigationStage.h"
#import "CoreDataHelper.h"
#import "WMUserDefaultsManager.h"
#import "WCAppDelegate.h"

@interface WMPatientManager()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;
@property (readonly, nonatomic) WMUserDefaultsManager *userDefaultsManager;

@end

@implementation WMPatientManager

#pragma mark - Initialization

+ (WMPatientManager *)sharedInstance
{
    static WMPatientManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMPatientManager alloc] init];
    });
    return SharedInstance;
}

#pragma mark - Core

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
    return self.coreDataHelper.stackMobStore.contextForCurrentThread;
}

- (NSPersistentStore *)store
{
    return nil;
}

- (WMUserDefaultsManager *)userDefaultsManager
{
    return [WMUserDefaultsManager sharedInstance];
}

- (NSInteger)patientCount
{
    __block NSInteger count = 0;
    NSManagedObjectContext *context = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    [context performBlockAndWait:^{
        count = [WMPatient patientCount:context persistentStore:store];
    }];
    return count;
}

- (WMPatient *)lastModifiedActivePatient
{
    WMPatient *patient = nil;
    // attempt to access the last patient
    NSString *lastPatientId = self.userDefaultsManager.lastPatientId;
    NSManagedObjectContext *context = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    if (nil != lastPatientId) {
        patient = [WMPatient patientForPatientId:lastPatientId managedObjectContext:context persistentStore:store];
        if (nil == patient) {
            patient = [WMPatient lastModifiedActivePatient:context persistentStore:store];
        }
    } else {
        patient = [WMPatient lastModifiedActivePatient:context persistentStore:store];
    }
    return patient;
}

- (WMNavigationTrack *)navigationTrackForCurrentPatient:(NSManagedObjectContext *)managedObjectContext
                                        persistentStore:(NSPersistentStore *)store
{
    WMNavigationTrack *navigationTrack = nil;
    WMPatient *patient = self.appDelegate.patient;
    WMUserDefaultsManager *userDefaultsManager = self.userDefaultsManager;
    if (nil == patient) {
        navigationTrack = [userDefaultsManager defaultNavigationTrack:managedObjectContext persistentStore:store];
    } else {
        navigationTrack = patient.stage.track;
        if (nil == navigationTrack) {
            navigationTrack = [userDefaultsManager defaultNavigationTrack:managedObjectContext persistentStore:store];
        }
    }
    return navigationTrack;
}

@end

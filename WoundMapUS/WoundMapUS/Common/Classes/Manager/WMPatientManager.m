//
//  WMPatientManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/14/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientManager.h"
#import "WMPatient.h"
#import "WMPerson.h"
#import "WMPatientConsultant.h"
#import "User.h"
#import "WMParticipant.h"
#import "WMNavigationStage.h"
#import "CoreDataHelper.h"
#import "WMUserDefaultsManager.h"
#import "WMNavigationCoordinator.h"
#import "WMUtilities.h"
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
    return [self.coreDataHelper.stackMobStore contextForCurrentThread];
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
    NSManagedObjectContext *context = self.managedObjectContext;
    NSPersistentStore *store = self.store;
    __block NSInteger count = 0;
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
    WMPatient *patient = self.appDelegate.navigationCoordinator.patient;
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

#pragma mark - StackMob Support

- (void)acquirePatientRecordsWithCompletionHandler:(void (^)(NSError *))handler
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CoreDataHelper *coreDataHelper = self.appDelegate.coreDataHelper;
        NSManagedObjectContext *stackMobContext = [coreDataHelper.stackMobStore contextForCurrentThread];
        SMRequestOptions *requestOptions = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyTryNetworkElseCache];
        NSError *error = nil;
        // fetch patients and associated person/consultant
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"WMPatient" inManagedObjectContext:stackMobContext]];
        NSArray *patients = [stackMobContext executeFetchRequestAndWait:request returnManagedObjectIDs:NO options:requestOptions error:&error];
        if (nil != error) {
            handler(error);
        }
        DLog(@"Acquired %d WMPatients from network", [patients count]);
        // forces update of related objects
        for (WMPatient *patient in patients) {
            WMPerson *person = patient.person;
            if ([person.nameFamily length] == 0) {
                DLog(@"person.nameFamily length 0: %@", person);
            }
            NSSet *patientConsultants = patient.patientConsultants;
            for (WMPatientConsultant *patientConsultant in patientConsultants) {
                NSString *consultantUserName = patientConsultant.consultant.username;
                DLog(@"Patient has consultant: %@", consultantUserName);
            }
        }
        // fetch patientConsultant and associated consultant/participant/patient
        request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"WMPatientConsultant" inManagedObjectContext:stackMobContext]];
        NSArray *patientConsultants = [stackMobContext executeFetchRequestAndWait:request returnManagedObjectIDs:NO options:requestOptions error:&error];
        if (nil != error) {
            handler(error);
        }
        DLog(@"Acquired %d WMPatientConsultant from network", [patientConsultants count]);
        // forces update of related objects
        for (WMPatientConsultant *patientConsultant in patientConsultants) {
            User *consultant = patientConsultant.consultant;
            if ([consultant.username length] == 0) {
                DLog(@"consultant.username length 0: %@", consultant);
            }
            WMParticipant *participant = patientConsultant.participant;
            if ([participant.name length] == 0) {
                DLog(@"participant.name length 0: %@", participant);
            }
            WMPatient *patient = patientConsultant.patient;
            if ([patient.person.nameFamily length] == 0) {
                DLog(@"patient.person.nameFamily length 0: %@", patient);
            }
        }
        handler(nil);
    });
}


@end

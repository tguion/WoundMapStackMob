//
//  WMSeedDatabaseManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/15/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMSeedDatabaseManager.h"
#import "WMInstruction.h"
#import "WMParticipantType.h"
#import "WMParticipantType.h"
#import "WMWoundType.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMPatient.h"
#import "WMBradenCare.h"
#import "WMWoundType.h"
#import "WMDefinition.h"
#import "WMInstruction.h"
#import "IAPProduct.h"
#import "WMAmountQualifier.h"
#import "WMWoundOdor.h"
#import "WMInterventionStatus.h"
#import "WMTeam.h"
#import "CoreDataHelper.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMSeedDatabaseManager ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@end

@implementation WMSeedDatabaseManager

#pragma mark - Initialization

+ (WMSeedDatabaseManager *)sharedInstance
{
    static WMSeedDatabaseManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMSeedDatabaseManager alloc] init];
    });
    return SharedInstance;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)seedDatabaseWithCompletionHandler:(void (^)(NSError *))handler
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DLog(@"reading plists and seeding database start");
        [WMBradenCare seedDatabase:managedObjectContext];
        [WMDefinition seedDatabase:managedObjectContext];
        [WMInstruction seedDatabase:managedObjectContext];
        // *** WMWoundType *** first attempt to acquire data from backend
        NSArray *objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundType entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMWoundType seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
                // update backend
                [ffm createArray:objectIDs
                      collection:collection
                              ff:ff
                      addToQueue:YES
                reverseEnumerate:YES
               completionHandler:nil];
            }];
        }
        // *** WMParticipantType *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMParticipantType entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMParticipantType seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
                // update backend
                [ffm createArray:objectIDs
                      collection:collection
                              ff:ff
                      addToQueue:YES
               completionHandler:nil];
            }];
        }
        // *** WMAmountQualifier *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMAmountQualifier entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMAmountQualifier seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
                // update backend
                [ffm createArray:objectIDs
                      collection:collection
                              ff:ff
                      addToQueue:YES
               completionHandler:nil];
            }];
        }
        // *** WMWoundOdor *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundOdor entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMWoundOdor seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
                // update backend
                [ffm createArray:objectIDs
                      collection:collection
                              ff:ff
                      addToQueue:YES
               completionHandler:nil];
            }];
        }
        // *** WMInterventionStatus *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMInterventionStatus entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMInterventionStatus seedDatabase:managedObjectContext completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
                // update backend
                [ffm createArray:objectIDs
                      collection:collection
                              ff:ff
                      addToQueue:YES
               completionHandler:nil];
            }];
        }
//        [WCInterventionEventType seedDatabase:managedObjectContext persistentStore:nil];
//        [WMMedicationCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMDeviceCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMSkinAssessmentCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMCarePlanCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WCWoundLocation seedDatabase:managedObjectContext persistentStore:nil];
//        [WMWoundTreatment seedDatabase:managedObjectContext persistentStore:nil];
//        [WMWoundMeasurement seedDatabase:managedObjectContext persistentStore:nil];
//        [WMPsychoSocialItem seedDatabase:stackMobContext persistentStore:nil];
        DLog(@"reading plists and seeding database finished");
        if (handler) {
            handler(nil);
        }
    });
}

- (void)seedTeamDatabase:(WMTeam *)team completionHandler:(void (^)(NSError *))handler
{
    NSParameterAssert([team.ffUrl length] > 0);
    if ([team.navigationTracks count]) {
        return;
    }
    // else
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WMNavigationTrack seedDatabaseForTeam:team completionHandler:^(NSError *error, NSArray *objectIDs, NSString *collection) {
            // update backend
            [ffm createArray:objectIDs
                  collection:collection
                          ff:ff
                  addToQueue:YES
           completionHandler:nil];
        }];
    });
}

@end

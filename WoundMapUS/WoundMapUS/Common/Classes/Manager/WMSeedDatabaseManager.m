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
#import "WMInterventionEventType.h"
#import "WMMedicationCategory.h"
#import "WMDeviceCategory.h"
#import "WMSkinAssessmentCategory.h"
#import "WMCarePlanCategory.h"
#import "WMWoundLocation.h"
#import "WMWoundTreatment.h"
#import "WMWoundMeasurement.h"
#import "WMPsychoSocialItem.h"
#import "WMTelecomType.h"
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
        WMProcessCallback completionHandler = ^(NSError *error, NSArray *objectIDs, NSString *collection) {
            // update backend
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
            for (NSManagedObjectID *objectID in objectIDs) {
                NSManagedObject *object = [managedObjectContext objectWithID:objectID];
                NSLog(@"*** WoundMap: Will create collection backend: %@", object);
                [ff createObj:object atUri:ffUrl];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        };
        DLog(@"reading plists and seeding database start");
//        [WMBradenCare seedDatabase:managedObjectContext];
//        [WMDefinition seedDatabase:managedObjectContext];
//        [WMInstruction seedDatabase:managedObjectContext];
        // GARY: this seed appears to work - I think I need it for the WMWoundTreatment seed
        // *** WMWoundType *** first attempt to acquire data from backend
        NSArray *objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundType entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMWoundType seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        /* the following seed calls appear to work - for now concentrate on WMWoundTreatment
        // *** WMParticipantType *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMParticipantType entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMParticipantType seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMAmountQualifier *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMAmountQualifier entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMAmountQualifier seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMWoundOdor *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundOdor entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMWoundOdor seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMInterventionStatus *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMInterventionStatus entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMInterventionStatus seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMInterventionEventType *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMInterventionEventType entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMInterventionEventType seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMMedicationCategory *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMMedicationCategory entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMMedicationCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMDeviceCategory *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMDeviceCategory entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMDeviceCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMSkinAssessmentCategory *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMSkinAssessmentCategory entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMSkinAssessmentCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMCarePlanCategory *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMCarePlanCategory entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMCarePlanCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WCWoundLocation *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundLocation entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMWoundLocation seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
         */
        // GARY: here's the seed (at least one of them) that I can't get past
        // *** WMWoundTreatment *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundTreatment entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMWoundTreatment seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        /*
        // *** WMWoundMeasurement *** first attempt to acquire data from backend
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundMeasurement entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMWoundMeasurement seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        // *** WMPsychoSocialItem *** first attempt to acquire data from backend GARY: this is another section that is crashing
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMPsychoSocialItem entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMPsychoSocialItem seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
        objects = [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMTelecomType entityName]]];
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if ([objects count] == 0) {
            [WMTelecomType seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
         */
        DLog(@"reading plists and seeding database finished");
        [managedObjectContext reset];
        [NSManagedObjectContext MR_clearContextForCurrentThread];
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

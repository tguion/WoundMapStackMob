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
#import "WMMedicalHistoryItem.h"
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
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMSeedDatabaseManager ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (strong, nonatomic) NSOperationQueue *serialQueue;

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

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _serialQueue = [[NSOperationQueue alloc] init];
    _serialQueue.name = @"Serial Queue";
    _serialQueue.maxConcurrentOperationCount = 1;
    
    return self;
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)seedDatabaseWithCompletionHandler:(void (^)(NSError *))handler
{
    WM_ASSERT_MAIN_THREAD;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    WMProcessCallback completionHandler = ^(NSError *error, NSArray *objectIDs, NSString *collection) {
        // update backend from main thread
        NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
        for (NSManagedObjectID *objectID in objectIDs) {
            NSManagedObject *object = [managedObjectContext objectWithID:objectID];
            NSLog(@"*** WoundMap: Will create collection backend: %@", object);
            [ff createObj:object atUri:ffUrl];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }
    };
    DLog(@"reading plists and seeding database start");
    [WMBradenCare seedDatabase:managedObjectContext];
    [WMDefinition seedDatabase:managedObjectContext];
    [WMInstruction seedDatabase:managedObjectContext];
    // *** WMWoundType *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundType seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMMedicalHistoryItem *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMMedicalHistoryItem entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMMedicalHistoryItem seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMNavigationTrack *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMNavigationTrack entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMNavigationTrack seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMParticipantType *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMParticipantType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMParticipantType seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMAmountQualifier *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMAmountQualifier entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMAmountQualifier seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMWoundOdor *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundOdor entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundOdor seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMInterventionStatus *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMInterventionStatus entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMInterventionStatus seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMInterventionEventType *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMInterventionEventType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMInterventionEventType seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMMedicationCategory *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMMedicationCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMMedicationCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMDeviceCategory *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMDeviceCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMDeviceCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMSkinAssessmentCategory *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMSkinAssessmentCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMSkinAssessmentCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMCarePlanCategory *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMCarePlanCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMCarePlanCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WCWoundLocation *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundLocation entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundLocation seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMWoundTreatment *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundTreatment entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundTreatment seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMWoundMeasurement *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundMeasurement entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundMeasurement seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMPsychoSocialItem *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMPsychoSocialItem entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMPsychoSocialItem seedDatabase:managedObjectContext completionHandler:completionHandler];
        }
    }];
    // *** WMTelecomType *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMTelecomType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMTelecomType seedDatabase:managedObjectContext completionHandler:completionHandler];
            DLog(@"reading plists and seeding database finished");
            handler(nil);
        } else {
            handler(nil);
        }
    }];
}

@end

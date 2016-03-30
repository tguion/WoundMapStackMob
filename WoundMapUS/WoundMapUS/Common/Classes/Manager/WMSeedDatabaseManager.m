//
//  WMSeedDatabaseManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/15/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
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
#import "WMNutritionItem.h"
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

- (BOOL)databaseSeedHasCompleted
{
    return [WMWoundType woundTypeCount:[NSManagedObjectContext MR_defaultContext]] > 0;
}

- (void)seedLocalData:(NSManagedObjectContext *)managedObjectContext
{
    [WMBradenCare seedDatabase:managedObjectContext];
    [WMDefinition seedDatabase:managedObjectContext];
    [WMInstruction seedDatabase:managedObjectContext];
    [IAPProduct seedDatabase:managedObjectContext];
}

- (void)seedNavigationTrackWithCompletionHandler:(void (^)(NSError *))handler
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    CoreDataHelper *coreDataHelper = [CoreDataHelper sharedInstance];
    __block NSInteger counter = 0;
    WMProcessCallbackWithCallback completionHandler = ^(NSError *error, NSArray *objectIDs, NSString *collection, dispatch_block_t callBack) {
        if (error) {
            [WMUtilities logError:error];
        }
        // update backend from main thread
        NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
        for (NSManagedObjectID *objectID in objectIDs) {
            NSManagedObject *object = [managedObjectContext objectWithID:objectID];
            NSLog(@"*** WoundMap: Will create collection backend: %@", object);
            [ff createObj:object atUri:ffUrl];
            [coreDataHelper markBackendDataAcquiredForEntityName:collection];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }
        if (callBack) {
            callBack();
        }
        if (counter == 0 || --counter == 0) {
            handler(nil);
        }
    };
    dispatch_block_t counterHandler = ^{
        if (counter == 0 || --counter == 0) {
            handler(nil);
        }
    };
    DLog(@"reading plists and seeding database start");
    // *** WMNavigationTrack *** first attempt to acquire data from backend
    counter += 5;   // WMNavigationTrack does 5 callbacks
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMNavigationTrack entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMNavigationTrack seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
}

- (void)seedDatabaseWithCompletionHandler:(void (^)(NSError *))handler
{
    WM_ASSERT_MAIN_THREAD;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    CoreDataHelper *coreDataHelper = [CoreDataHelper sharedInstance];
    __block NSInteger counter = 0;
    WMProcessCallbackWithCallback completionHandler = ^(NSError *error, NSArray *objectIDs, NSString *collection, dispatch_block_t callBack) {
        // update backend from main thread
        NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
        for (NSManagedObjectID *objectID in objectIDs) {
            NSManagedObject *object = [managedObjectContext objectWithID:objectID];
            NSLog(@"*** WoundMap: Will create collection backend: %@", object);
            [ff createObj:object atUri:ffUrl];
            [coreDataHelper markBackendDataAcquiredForEntityName:collection];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
        }
        if (callBack) {
            callBack();
        }
        if (counter == 0 || --counter == 0) {
            handler(nil);
        }
    };
    dispatch_block_t counterHandler = ^{
        if (counter == 0 || --counter == 0) {
            handler(nil);
        }
    };
//    DLog(@"reading plists and seeding database start");
//    // *** WMNavigationTrack *** first attempt to acquire data from backend
//    counter += 5;   // WMNavigationTrack does 5 callbacks
//    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMNavigationTrack entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
//        [managedObjectContext MR_saveToPersistentStoreAndWait];
//        if (![object count]) {
//            [WMNavigationTrack seedDatabase:managedObjectContext completionHandler:completionHandler];
//        } else {
//            counterHandler();
//        }
//    }];
    if (self.databaseSeedHasCompleted) {
        handler(nil);
        return;
    }
    // else
    [self seedLocalData:managedObjectContext];
    // *** WMWoundType *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundType seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMMedicalHistoryItem *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMMedicalHistoryItem entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMMedicalHistoryItem seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMParticipantType *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMParticipantType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMParticipantType seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMAmountQualifier *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMAmountQualifier entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMAmountQualifier seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMWoundOdor *** first attempt to acquire data from backend
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundOdor entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundOdor seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMInterventionStatus *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMInterventionStatus entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMInterventionStatus seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMInterventionEventType *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMInterventionEventType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMInterventionEventType seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMMedicationCategory *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMMedicationCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMMedicationCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMDeviceCategory *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMDeviceCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMDeviceCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMSkinAssessmentCategory *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMSkinAssessmentCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMSkinAssessmentCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMCarePlanCategory *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMCarePlanCategory entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMCarePlanCategory seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WCWoundLocation *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundLocation entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundLocation seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMWoundTreatment *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundTreatment entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundTreatment seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMWoundMeasurement *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMWoundMeasurement entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMWoundMeasurement seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMPsychoSocialItem *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMPsychoSocialItem entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMPsychoSocialItem seedDatabase:managedObjectContext completionHandler:completionHandler];
        } else {
            counterHandler();
        }
    }];
    // *** WMTelecomType *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMTelecomType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMTelecomType seedDatabase:managedObjectContext completionHandler:completionHandler];
            DLog(@"reading plists and seeding database finished");
        } else {
            counterHandler();
        }
    }];
    // *** WMNutritionItem *** first attempt to acquire data from backend
    ++counter;
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMNutritionItem entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (![object count]) {
            [WMNutritionItem seedDatabase:managedObjectContext completionHandler:completionHandler];
            DLog(@"reading plists and seeding database finished");
        } else {
            counterHandler();
        }
    }];
}

@end

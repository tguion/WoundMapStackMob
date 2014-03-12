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
#import "CoreDataHelper.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"
#import "StackMob.h"

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

- (void)seedTeamDatabaseWithCompletionHandler:(void (^)(NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CoreDataHelper *coreDataHelper = self.appDelegate.coreDataHelper;
        NSManagedObjectContext *stackMobContext = [coreDataHelper.stackMobStore contextForCurrentThread];
        DLog(@"reading plists and seeding database start");
        [WMInstruction seedDatabase:stackMobContext persistentStore:nil];
        [WMWoundType seedDatabase:stackMobContext persistentStore:nil];
        [WMParticipantType seedDatabase:stackMobContext persistentStore:nil];
//        [WCAmountQualifier seedDatabase:managedObjectContext persistentStore:nil];
//        [WCWoundOdor seedDatabase:managedObjectContext persistentStore:nil];
//        [WCInterventionStatus seedDatabase:managedObjectContext persistentStore:nil];
//        [WCInterventionEventType seedDatabase:managedObjectContext persistentStore:nil];
//        [WMMedicationCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMDeviceCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMSkinAssessmentCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WMCarePlanCategory seedDatabase:managedObjectContext persistentStore:nil];
//        [WCWoundLocation seedDatabase:managedObjectContext persistentStore:nil];
//        [WMWoundTreatment seedDatabase:managedObjectContext persistentStore:nil];
//        [WMWoundMeasurement seedDatabase:managedObjectContext persistentStore:nil];
        [WMNavigationTrack seedDatabase:stackMobContext persistentStore:nil];
//        [WMPsychoSocialItem seedDatabase:stackMobContext persistentStore:nil];
        DLog(@"reading plists and seeding database finished");
        SMRequestOptions *requestOptions = [SMRequestOptions optionsWithSavePolicy:SMSavePolicyNetworkThenCache];
        NSError *error = nil;
        [stackMobContext saveAndWait:&error options:requestOptions];
        handler(error);
    });
}

@end
